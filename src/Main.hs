{-# LANGUAGE OverloadedStrings #-}

import System.IO.Streams (InputStream, OutputStream, stdout)
import qualified System.IO.Streams as Streams
import qualified Data.ByteString as S


import qualified Network.Http.Client as C

process :: C.Response -> InputStream S.ByteString -> IO ()
process resp input = 
    Streams.read input >>= \xm ->
        case xm of
            Just x    -> S.putStr x
            Nothing   -> S.putStr "What?\n"

main :: IO ()
main = 
    C.baselineContextSSL >>= \ctx ->
    C.openConnectionSSL ctx "www.vg.no" 443  >>= \conn -> 
    let req = C.buildRequest1 $
                C.http C.GET "/" >>
                C.setAccept "text/html"
    in
    C.sendRequest conn req C.emptyBody >>
    C.receiveResponse conn process >>
    {-
    C.receiveResponse c (\p i -> 
                            Streams.read i >>= \xm ->
                                case xm of
                                    Just x    -> S.putStr x
                                    Nothing   -> S.putStr "What?\n") >>
    -}
    C.closeConnection conn

{-
mainx :: IO ()
mainx = do
    c <- C.openConnection "www.google.com" 80

    let q = C.buildRequest1 $ do
                C.http C.GET "/"
                C.setAccept "text/html"

    C.sendRequest c q C.emptyBody

    C.receiveResponse c (\p i -> do
                            xm <- Streams.read i
                            case xm of
                                Just x    -> S.putStr x
                                Nothing   -> S.putStr "What?\n")

    C.closeConnection c
  -}
