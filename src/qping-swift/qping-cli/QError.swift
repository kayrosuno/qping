//
//  QError.swift
//  qping
//
//  Created by Alejandro on 27/4/25.
//



///Enum errores
enum QError: Error {
    case invalidAddress(error: String)
    case invalidPort(error: String)
    case generic(error: String)
}
