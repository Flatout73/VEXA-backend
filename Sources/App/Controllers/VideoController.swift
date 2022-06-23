//
//  File.swift
//  
//
//  Created by Leonid Lyadveykin on 23.06.2022.
//

import Foundation
import Vapor

struct VideoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let contents = routes.grouped("video")
        contents.on(.GET, ":x", use: getVideo)

        contents.on(.POST, "uploadVideo", body: .stream, use: uploadVideo)
    }

    func getVideo(req: Request) throws -> Response {
        guard let filename = req.parameters.get("x", as: String.self) else {
            throw Abort(.badRequest)
        }
        let path = req.application.directory.publicDirectory + filename

        return req.fileio.streamFile(at: path)
    }

    func uploadVideo(req: Request) -> EventLoopFuture<String> {
        let fileName = (try? req.query.get(String.self, at: "filename")) ?? fileFormatter.string(from: Date()) + "pilot"
        let path = req.application.directory.publicDirectory + fileName

        var sequential = req.eventLoop.makeSucceededFuture(())
        let io = req.application.fileio
        return io.openFile(path: path, mode: .write, flags: .allowFileCreation(), eventLoop: req.eventLoop).flatMap { handle -> EventLoopFuture<Void> in
                let promise = req.eventLoop.makePromise(of: Void.self)

                req.body.drain {
                    switch $0 {
                    case .buffer(let chunk):
                        sequential = sequential.flatMap {
                            io.write(fileHandle: handle, buffer: chunk, eventLoop: req.eventLoop)
                        }
                        return sequential
                    case .error(let error):
                        promise.fail(error)
                        return req.eventLoop.makeSucceededFuture(())
                    case .end:
                        promise.succeed(())
                        return req.eventLoop.makeSucceededFuture(())
                    }
                }

                return promise.futureResult.flatMap {
                    sequential
                }.always { result in
                    _ = try? handle.close()
                }
            }
        .map { _ in
            let serverConfig = req.application.http.server.configuration
            let hostname = serverConfig.hostname
            let port = serverConfig.port
            return "\(hostname):\(port)/\(fileName)"
        }

    //    let r = Response(body: .init(stream: { writer in
//        req.body.drain({ body in
//            switch body {
//            case .buffer(let buffer):
//                return req.fileio.writeFile(buffer, at: path)
//            case .error(let error):
//                print(error)
//                // return writer.write(.error(error))
//            case .end:
//                return EventLoopFuture
//                // req.fileio.
//                //return writer.write(.end)
//            }
//        })
//

//
//            return "\(hostname):\(port)/\(fileName)"
  //         }, count: 0))
//        let file = try req.content.decode(File.self)
//
//        let prefix = fileFormatter.string(from: .init())


        //try await req.fileio.writeFile(file.data, at: path)
    }
}
