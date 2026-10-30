plugins {
    kotlin("jvm") version "2.0.21"
    application
}

group = "com.bankease.experiments"
version = "1.0.0"

kotlin {
    jvmToolchain(21)
}

application {
    mainClass.set("MainKt")
}
