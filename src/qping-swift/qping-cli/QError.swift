//
//  QError.swift
//  qping
//
//  Created by Alejandro on 18/4/25.
//



enum QError: Error
{
    case invalidAddress (error: String)
    case invalidPort (error: String)
}
