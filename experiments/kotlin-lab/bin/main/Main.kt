/*
 * BankEase Kotlin Lab
 *
 * Experiment 5: Kotlin fundamentals
 * Experiment 6: Functional operations and exception handling
 */

data class BankCustomer(
    val name: String,
    val age: Int,
    val active: Boolean
)

// A class groups data and behavior together.
open class AccountHolder(val name: String) {
    open fun describeRole(): String = "Account holder: $name"
}

// Inheritance: StudentAccount reuses AccountHolder and overrides behavior.
class StudentAccount(name: String, val course: String) : AccountHolder(name) {
    override fun describeRole(): String = "$name is a student studying $course"
}

class BankAccount(
    val accountNumber: String,
    var balance: Double
) {
    fun deposit(amount: Double) {
        balance += amount
    }

    fun summary(): String = "$accountNumber has balance ₹${"%.2f".format(balance)}"
}

// An object creates one shared configuration instance.
object LabConfiguration {
    const val LAB_NAME = "BankEase Kotlin Lab"
}

class InvalidAmountException(message: String) : Exception(message)

fun main() {
    println("=".repeat(64))
    println(LabConfiguration.LAB_NAME)
    println("Experiments 5 and 6: Kotlin/JVM demonstrations")
    println("=".repeat(64))

    runExperiment5()
    runExperiment6()
}

fun runExperiment5() {
    println("\nEXPERIMENT 5 — KOTLIN FUNDAMENTALS")

    // val cannot be reassigned; var can be reassigned.
    val bankName: String = "BankEase"
    var openingBalance: Double = 2500.0
    val accountIsActive: Boolean = true
    val accountAge: Int = 2
    openingBalance += 500.0

    println("Variables and data types:")
    println("  bankName (String): $bankName")
    println("  openingBalance (Double): ₹$openingBalance")
    println("  accountAge (Int): $accountAge")
    println("  accountIsActive (Boolean): $accountIsActive")

    val accountTypes: List<String> = listOf("Savings", "Current", "Student")
    val supportedChannels: Set<String> = setOf("Web", "Mobile", "ATM", "Web")
    val accountLimits: Map<String, Double> = mapOf(
        "Savings" to 100000.0,
        "Current" to 250000.0,
        "Student" to 25000.0
    )

    println("Collections:")
    println("  List: $accountTypes")
    println("  Set removes duplicates: $supportedChannels")
    println("  Map: $accountLimits")

    val customer = BankCustomer("Demo Customer", 20, true)
    val account = BankAccount("DEMO-1001", 1500.0)
    account.deposit(750.0)

    println("Classes and objects:")
    println("  Data class: $customer")
    println("  Class method: ${account.summary()}")
    println("  Object constant: ${LabConfiguration.LAB_NAME}")

    val studentAccount = StudentAccount("Aarav", "Computer Applications")
    println("Inheritance and overriding:")
    println("  ${studentAccount.describeRole()}")
}

fun runExperiment6() {
    println("\nEXPERIMENT 6 — FUNCTIONAL OPERATIONS AND EXCEPTION HANDLING")

    println("try-catch-finally:")
    try {
        val parsedAmount = "not-a-number".toDouble()
        println("  Parsed amount: $parsedAmount")
    } catch (exception: NumberFormatException) {
        println("  Caught NumberFormatException: invalid numeric input")
    } finally {
        println("  Finally always runs: input handling finished")
    }

    println("throw and custom exception:")
    try {
        validateTransferAmount(-50.0)
    } catch (exception: InvalidAmountException) {
        println("  Caught InvalidAmountException: ${exception.message}")
    }

    val transactions = listOf(1200.0, -300.0, 450.0, -100.0, 800.0)
    val deposits = transactions.filter { amount -> amount > 0 }
    val rupeeAmounts = deposits.map { amount -> "₹${"%.2f".format(amount)}" }
    val totalDeposits = deposits.reduce { total, amount -> total + amount }

    println("map, filter, and reduce:")
    println("  Original transactions: $transactions")
    println("  filter (deposits only): $deposits")
    println("  map (formatted amounts): $rupeeAmounts")
    println("  reduce (total deposits): ₹$totalDeposits")
}

fun validateTransferAmount(amount: Double) {
    if (amount <= 0) {
        throw InvalidAmountException("Transfer amount must be greater than zero")
    }
}
