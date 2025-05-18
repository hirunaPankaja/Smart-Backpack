// Top-level build file for Android using Kotlin DSL

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
