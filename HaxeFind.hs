module HaxeFind where
import System.Directory
import Data.List
import Control.Monad

{-main :: IO ()
main = do
    hpath <- getEnv "HAXEPATH"
    putStrLn hpath-}


findClasses :: String -> String -> IO [String]
findClasses haxePath iml = do
    a <- findClassesInStd haxePath iml
    b <- findClassesInLibs haxePath iml
    return $ a ++ b

findClassesLocal :: String -> String -> IO [String]
findClassesLocal path iml = do
    findNextFieldEx ".as" path $ split '.' iml

findClassesInStd :: String -> String -> IO [String]
findClassesInStd haxePath iml = do
    stdResult <- findNextField (haxePath ++ "std") $ split '.' iml
    flashResult <- findNextField (haxePath ++ "std\\flash") $ split '.' iml
    return $ stdResult ++ flashResult

findClassesInLibs :: String -> String -> IO [String]
findClassesInLibs haxePath iml = do
    libList <- getDirectoryContents (haxePath ++ "lib\\") >>= filterM (return . (/=".")) >>= filterM (return . (/=".."))
    classes <- mapM (findClassesInLib haxePath iml) libList
    return $ foldr (++) [] classes

findClassesInLib :: String -> String-> String -> IO [String]
findClassesInLib haxePath iml libName = do
    content <- readFile $ libPath ++ "\\.current"
    findNextField (libPath ++ '\\':replace '.' ',' content) imlist
    where
        imlist = split '.' iml
        libPath = haxePath ++ "lib\\" ++ libName

findNextField :: String -> [String] -> IO [String]
findNextField = findNextFieldEx ".hx"

findNextFieldEx :: String -> String -> [String] -> IO [String]
findNextFieldEx ex path [] = do error "Invalid import clause."
findNextFieldEx ex path ["*;"] = do
    b <- doesDirectoryExist path
    if b
    then getDirectoryContents path >>= filterM (return . isSuffixOf ex) >>= mapM (return . stripSuffix ex)
    else return []
findNextFieldEx ex path iml = findNextFieldEx ex (path ++ '\\':head iml) $ tail iml

        

-- Helper

split :: Eq a => a -> [a] -> [[a]]
split c [] = []
split c s = first : split c rest
    where (first, rest) = break (==c) $ dropWhile (==c) s

stripSuffix :: Eq a => [a] -> [a] -> [a] 
stripSuffix suffix s =
    if isSuffixOf suffix s then
        take (length s - length suffix) s
    else
        s

replace :: Eq a => a -> a -> [a] -> [a]
replace c newC [] = []
replace c newC (x:xs) =
    if x == c then
        newC:replace c newC xs
    else
        x:replace c newC xs

