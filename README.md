# Injection Foundation

A simple "tweak injection" tweak for those apps that don't import UIKit framework but are also GUI applications.

Every GUI application imports Foundation framework. It's not always the case for UIKit and many developers assume that GUI applications are to be filtered via UIKit only.

As a result, those apps won't support tweaks that target UIKit only.

Unity apps are the obvious examples of this: https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html
