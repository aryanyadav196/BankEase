# BankEase Kotlin Lab

This is a standalone Kotlin/JVM console module for BankEase Experiments 5 and 6. It does not connect to the Spring Boot backend, MySQL database, JWT authentication, or any BankEase production data.

## Experiments covered

### Experiment 5 — Kotlin fundamentals

`Main.kt` demonstrates:

- `val` and `var`
- `String`, `Int`, `Double`, and `Boolean` data types
- `List`, `Set`, and `Map`
- Data classes
- Classes and methods
- Singleton objects
- Open classes, inheritance, and method overriding

### Experiment 6 — Functional operations and exception handling

`Main.kt` demonstrates:

- `try`, `catch`, and `finally`
- `throw`
- A custom `InvalidAmountException`
- `filter`, `map`, and `reduce`
- Clear console output for each operation

## Prerequisites

- Java 21
- Gradle 8.x or newer available as `gradle`
- Internet access on the first build so Gradle can obtain the Kotlin Gradle plugin from Maven Central

The current BankEase environment has Java 21, but does not currently have `gradle`, `kotlinc`, or `kotlin` available. Therefore this module has not been claimed as locally executed yet.

## Run the lab

From PowerShell:

```powershell
cd C:\BankEase\experiments\kotlin-lab
gradle run
```

Build without running:

```powershell
gradle build
```

If a Gradle wrapper is generated later, the equivalent Windows commands are:

```powershell
.\gradlew.bat run
.\gradlew.bat build
```

## Expected output

The program prints sections similar to:

```text
EXPERIMENT 5 — KOTLIN FUNDAMENTALS
Variables and data types:
  bankName (String): BankEase
Collections:
  List: [Savings, Current, Student]
  Set removes duplicates: [Web, Mobile, ATM]
Classes and objects:
  Data class: BankCustomer(...)
Inheritance and overriding:
  Aarav is a student studying Computer Applications

EXPERIMENT 6 — FUNCTIONAL OPERATIONS AND EXCEPTION HANDLING
try-catch-finally:
  Caught NumberFormatException: invalid numeric input
  Finally always runs: input handling finished
throw and custom exception:
  Caught InvalidAmountException: Transfer amount must be greater than zero
map, filter, and reduce:
  filter (deposits only): [1200.0, 450.0, 800.0]
  reduce (total deposits): ₹2450.0
```

The exact formatting of object output and currency values can vary by JVM locale.
