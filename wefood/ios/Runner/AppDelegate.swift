import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var flutterViewController: FlutterViewController!

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Inicializa el FlutterViewController
        flutterViewController = FlutterViewController()

        // Si estás usando un UINavigationController, establece el rootViewController
        let navigationController = UINavigationController(rootViewController: flutterViewController)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        // Registra los plugins con el FlutterViewController
        GeneratedPluginRegistrant.register(with: flutterViewController)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Sobrescribe funciones para redirigir las llamadas de plugin
    override func registrar(forPlugin pluginKey: String) -> FlutterPluginRegistrar? {
        flutterViewController.registrar(forPlugin: pluginKey)
    }

    override func hasPlugin(_ pluginKey: String) -> Bool {
        flutterViewController.hasPlugin(pluginKey)
    }

    override func valuePublished(byPlugin pluginKey: String) -> NSObject? {
        flutterViewController.valuePublished(byPlugin: pluginKey)
    }
}
