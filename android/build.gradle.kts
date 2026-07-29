allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Fallback for older Flutter plugins missing AGP 8+ namespace.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
            if (namespace.isNullOrEmpty()) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                val packageFromManifest = if (manifestFile.exists()) {
                    Regex("""package\s*=\s*"([^"]+)"""")
                        .find(manifestFile.readText())
                        ?.groupValues
                        ?.getOrNull(1)
                } else {
                    null
                }
                namespace = packageFromManifest ?: "com.flutter.plugins.${project.name}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
