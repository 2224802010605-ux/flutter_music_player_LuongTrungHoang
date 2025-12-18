import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete

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

/**
 * AGP 8+ FIX pack:
 * 1) Inject missing `namespace` for old Android plugins (e.g. on_audio_query_android 1.1.0)
 * 2) Remove deprecated `package="..."` in library AndroidManifest.xml (AGP 8+ rejects it)
 * 3) Force consistent JVM target for Java & Kotlin WITHOUT using --release
 *    (fixes 1.8 vs 21 mismatch and avoids AGP bootclasspath issue)
 */
subprojects {

    fun ensureNamespace() {
        val androidExt = extensions.findByName("android") ?: return
        try {
            val getNamespace = androidExt.javaClass.methods.firstOrNull {
                it.name == "getNamespace" && it.parameterCount == 0
            }
            val setNamespace = androidExt.javaClass.methods.firstOrNull {
                it.name == "setNamespace" && it.parameterCount == 1
            }

            if (setNamespace != null) {
                val current = getNamespace?.invoke(androidExt) as? String
                if (current.isNullOrBlank()) {
                    val fixed = "com.fix.${project.name.replace("-", "_")}"
                    setNamespace.invoke(androidExt, fixed)
                }
            }
        } catch (_: Throwable) {
            // ignore
        }
    }

    fun patchPluginManifestPackage() {
        tasks.matching { t ->
            t.name.startsWith("process") && t.name.endsWith("Manifest")
        }.configureEach {
            doFirst {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (!manifestFile.exists()) return@doFirst

                val original = manifestFile.readText()
                val patched = original.replace(Regex("""\s+package="[^"]+""""), "")
                if (patched != original) {
                    manifestFile.writeText(patched)
                }
            }
        }
    }

    fun forceJvm17Safe() {
        val androidExt = extensions.findByName("android") ?: return

        // Set Android compileOptions source/target to Java 17 (NO --release)
        try {
            val getCompileOptions = androidExt.javaClass.methods.firstOrNull {
                it.name == "getCompileOptions" && it.parameterCount == 0
            }
            val compileOptionsObj = getCompileOptions?.invoke(androidExt)

            val setSource = compileOptionsObj?.javaClass?.methods?.firstOrNull {
                it.name == "setSourceCompatibility" && it.parameterCount == 1
            }
            val setTarget = compileOptionsObj?.javaClass?.methods?.firstOrNull {
                it.name == "setTargetCompatibility" && it.parameterCount == 1
            }

            val javaVersionClass = Class.forName("org.gradle.api.JavaVersion")
            val toVersion = javaVersionClass.methods.firstOrNull { it.name == "toVersion" && it.parameterCount == 1 }
            val v17 = toVersion?.invoke(null, 17)

            if (v17 != null) {
                setSource?.invoke(compileOptionsObj, v17)
                setTarget?.invoke(compileOptionsObj, v17)
            }
        } catch (_: Throwable) {
            // ignore
        }

        // Force Kotlin jvmTarget = 17
        tasks.matching { it.name.contains("Kotlin") }.configureEach {
            try {
                val getKotlinOptions = this.javaClass.methods.firstOrNull { m ->
                    m.name == "getKotlinOptions" && m.parameterCount == 0
                }
                val kotlinOptionsObj = getKotlinOptions?.invoke(this)
                val setJvmTarget = kotlinOptionsObj?.javaClass?.methods?.firstOrNull { m ->
                    m.name == "setJvmTarget" && m.parameterCount == 1
                }
                setJvmTarget?.invoke(kotlinOptionsObj, "17")
            } catch (_: Throwable) {
                // ignore
            }
        }
    }

    plugins.withId("com.android.library") {
        ensureNamespace()
        patchPluginManifestPackage()
        forceJvm17Safe()
    }
    plugins.withId("com.android.application") {
        ensureNamespace()
        patchPluginManifestPackage()
        forceJvm17Safe()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
