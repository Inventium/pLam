import Config
import Syntax
import Parser
import Evaluator
import Reducer
import Helper

import Control.Monad.State
import System.IO (hFlush, stdout, hPutStrLn, hClose, openFile, IOMode(WriteMode))
import Debug.Trace
import System.Exit
import System.Console.Haskeline
import System.Environment
import System.Directory (doesFileExist)


version = "2.2.1"
heading = "\x1b[1;36m\
\         _\n\
\        | |\n\
\    ____| |   ___  __  __\n\
\    | _ \\ |__| _ \\|  \\/  |\n\
\    |  _/____|____\\_\\__/_| \x1b[32mv"++version++"\n\
\    \x1b[1;36m|_| \x1b[0mpure λ-calculus interpreter\n\
\   \x1b[1;36m=================================\n"
-------------------------------------------------------------------------------------

execAll :: [String] -> Environment -> InputT IO Environment
execAll [] env = return env
execAll (line:ls) env =
    case readLine line of
            Left (SyntaxError err) -> do
                outputStrLn (show err) 
                return env
            Right comm -> case comm of   
                Import f -> do
                    content <- liftIO $ readFile (importPath ++ f ++ ".plam")
                    let exprs = lines content
                    env' <- execAll exprs env
                    execAll ls env'
                Define v e ->
                    let (res, env') = (evalDefine v e) `runState` env in
                    case res of
                        Left err -> do
                            outputStrLn (show err)
                            execAll ls env'
                        Right f  -> execAll ls env'
                Evaluate det cbv e -> decideEvaluate env det cbv e
                Print s -> do
                    outputStrLn s
                    execAll ls env
                otherwise -> execAll ls env

execute :: String -> Environment -> InputT IO Environment
execute line env = 
    case readLine line of
            Left (SyntaxError e) -> do
                outputStrLn (show e)
                return env
            Right comm -> case comm of
                Define v e -> do
                    let (res, env') = (evalDefine v e) `runState` env
                    case res of
                        Left err -> outputStrLn (show err)
                        Right exp -> outputStr ""
                    return env'
                Evaluate det cbv e -> decideEvaluate env det cbv e
                Import f -> do
                    fileExists <- liftIO $ doesFileExist (importPath ++ f ++ ".plam")
                    if fileExists
                       then do
                            content <- liftIO $ readFile (importPath ++ f ++ ".plam")
                            let exprs = lines content
                            execAll exprs env
                       else do
                            outputStrLn("--- import failed : " ++ f ++ ".plam does not exist within import/")
                            return env
                Export f -> do
                    fileExists <- liftIO $ doesFileExist (importPath ++ f ++ ".plam")
                    if not fileExists
                        then do
                            outFile <- liftIO $ openFile (importPath ++ f ++ ".plam") WriteMode
                            liftIO $ mapM_ (saveGlobal outFile) (reverse env)
                            liftIO $ hClose outFile
                            outputStrLn("--- successfully exported to import/" ++ f ++ ".plam")
                        else
                            outputStrLn("--- export failed : " ++ f ++ " already exists")
                    return env
                Review r -> do
                    case r of
                       "all" ->
                           outputStrLn " ENVIRONMENT:"
                           >>
                           mapM_ showGlobal env
                       otherwise -> outputStrLn ("--- definition of " ++ show r ++ ": " ++ reviewVariable env r)
                    return env
                Run f -> do
                    content <- liftIO $ readFile (f ++ ".plam")
                    let exprs = lines content
                    execAll exprs env
                Print s -> do
                    outputStrLn s
                    outputStrLn ("(NOTE: it makes more sense to use a comment line (starts with double '-' than :print command when you are in interactive mode)")
                    return env
                Comment c -> return env

execJustProg :: [String] -> Environment -> IO Environment
execJustProg [] env = return env
execJustProg (line:ls) env =
    case readLine line of
            Left (SyntaxError err) -> do
                putStrLn (show err)
                return env
            Right comm -> case comm of   
                Import f -> do
                    content <- liftIO $ readFile (importPath ++ f ++ ".plam")
                    let exprs = lines content
                    env' <- execJustProg exprs env
                    execJustProg ls env'
                Define v e ->
                    let (res, env') = (evalDefine v e) `runState` env in
                    case res of
                        Left err -> do
                            putStrLn (show err)
                            execJustProg ls env'
                        Right f  -> execJustProg ls env'
                Evaluate det cbv e -> decideEvaluateProg env det cbv e
                Review r -> do
                    case r of
                       "all" -> do
                           putStrLn " ENVIRONMENT:"
                           mapM_ printGlobal env
                       otherwise -> putStrLn ("--- definition of " ++ show r ++ ": " ++ reviewVariable env r)
                    execJustProg ls env
                Print s -> do
                    putStrLn s
                    execJustProg ls env
                otherwise -> execJustProg ls env

-------------------------------------------------------------------------------------
isplam :: String -> Bool
isplam (c:cs)
    | (length cs == 5) && (cs == ".plam") = True
    | length cs < 5 = False
    | otherwise = isplam cs
       
-------------------------------------------------------------------------------------
                   -- MAIN with Read-Evaluate-Print Loop --
-------------------------------------------------------------------------------------
repl env = do
    mline <- getInputLine "\x1b[1;36mpLam>\x1b[0m "
    case mline of
        Nothing -> return ()
        Just line
            | line == ":quit" || line == ":q"-> do
                outputStrLn "\x1b[1;32mGoodbye!\x1b[0m"
                return ()
            | otherwise -> do
                env' <- execute line env
                repl env'

decideRun :: [String] -> IO()
decideRun args
    | length args == 0 = do
        putStrLn heading 
        runInput
    | (length args == 1) && (head args == ":nohead") = do
        runInput
    | (length args == 1) && (isplam (head args)) = do
        content <- readFile (head args)
        let exprs = lines content
        execJustProg exprs []
        putStrLn "\x1b[1;32mDone.\x1b[0m"
    | otherwise = do
        putStrLn "\x1b[31mignoring argument(s)...\x1b[0m"
        putStrLn heading 
        runInput
    where
      runInput = runInputT defaultSettings { historyFile = Just ".plam-history" } (repl [])

main :: IO ()
main = do
    args <- getArgs
    decideRun args
