import org.gradle.api.tasks.Delete
import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Place the Gradle build outputs outside the Android project folders so CI/tools
// can access a single top-level `build/` directory.
val newRootBuildDir: File = rootProject.projectDir.resolve("../../build")
rootProject.buildDir = newRootBuildDir

subprojects {
    project.buildDir = File(newRootBuildDir, project.name)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
