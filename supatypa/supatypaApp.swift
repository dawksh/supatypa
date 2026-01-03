//
//  supatypaApp.swift
//  supatypa
//
//  Created by Daksh on 03/01/26.
//

import SwiftUI

@main
struct supatypaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
            Settings { EmptyView() }
    }
}
