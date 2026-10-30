package com.bankease.backend.config;

import com.bankease.backend.entity.AutomationRule;
import com.bankease.backend.entity.AutomationRuleType;
import com.bankease.backend.entity.Role;
import com.bankease.backend.entity.User;
import com.bankease.backend.repository.AutomationRuleRepository;
import com.bankease.backend.repository.UserRepository;
import com.bankease.backend.service.UserService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.bankease.backend.entity.Customer;
import com.bankease.backend.repository.CustomerRepository;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initializeData(
                UserRepository userRepository,
                UserService userService,
                AutomationRuleRepository automationRuleRepository,
                CustomerRepository customerRepository
        ) {

        return args -> {

            createUserIfMissing(
                    userRepository,
                    userService,
                    "customer@bankease.com",
                    "Customer@123",
                    Role.CUSTOMER
            );

            createCustomerProfileIfMissing(
                        userRepository,
                        customerRepository,
                        "customer@bankease.com",
                        "Demo Customer",
                        "9876543210",
                        "BankEase Demo Address"
                );

            createUserIfMissing(
                    userRepository,
                    userService,
                    "employee@bankease.com",
                    "Employee@123",
                    Role.EMPLOYEE
            );

            createUserIfMissing(
                    userRepository,
                    userService,
                    "admin@bankease.com",
                    "Admin@123",
                    Role.ADMIN
            );

            createRuleIfMissing(
                    automationRuleRepository,
                    AutomationRuleType.BLOCKED_ACCOUNT,
                    "Blocked Account Rule",
                    "Reject transactions for blocked accounts."
            );

            createRuleIfMissing(
                    automationRuleRepository,
                    AutomationRuleType.CLOSED_ACCOUNT,
                    "Closed Account Rule",
                    "Reject transactions for closed accounts."
            );

            createRuleIfMissing(
                    automationRuleRepository,
                    AutomationRuleType.INSUFFICIENT_BALANCE,
                    "Insufficient Balance Rule",
                    "Reject withdrawals and transfers when balance is insufficient."
            );

            createRuleIfMissing(
                    automationRuleRepository,
                    AutomationRuleType.INVALID_AMOUNT,
                    "Invalid Amount Rule",
                    "Reject transactions when the amount is zero or negative."
            );

            createRuleIfMissing(
                    automationRuleRepository,
                    AutomationRuleType.OVERDUE_SERVICE_REQUEST,
                    "Overdue Service Request Rule",
                    "Escalate pending service requests that remain unresolved for more than 48 hours."
            );

            createRuleIfMissing(
                    automationRuleRepository,
                    AutomationRuleType.SUCCESSFUL_TRANSACTION,
                    "Successful Transaction Rule",
                    "Record successful transaction rule execution in the audit trail."
            );
        };
    }

    private void createUserIfMissing(
            UserRepository userRepository,
            UserService userService,
            String email,
            String password,
            Role role
    ) {

        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            user = userService.createUser(
                    email,
                    password,
                    role
            );

            System.out.println(
                    "BankEase demo user created: " + email
            );
        }

        // These fixed demo identities are for local testing, so they must
        // remain usable even if an older database contains them as pending.
        if (!user.isActive()) {
            user.setActive(true);
            userRepository.save(user);
        }
    }

    private void createRuleIfMissing(
            AutomationRuleRepository automationRuleRepository,
            AutomationRuleType type,
            String name,
            String description
    ) {

        if (automationRuleRepository.findByType(type).isEmpty()) {

            AutomationRule rule =
                    new AutomationRule();

            rule.setType(type);
            rule.setName(name);
            rule.setDescription(description);
            rule.setActive(true);

            automationRuleRepository.save(rule);

            System.out.println(
                    "BankEase automation rule created: "
                            + name
            );
        }
    }

    private void createCustomerProfileIfMissing(
                UserRepository userRepository,
                CustomerRepository customerRepository,
                String email,
                String fullName,
                String phone,
                String address
        ) {

        User user =
                userRepository.findByEmail(email)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Customer user not found: " + email
                                )
                        );

        if (customerRepository
                .findByUserId(user.getId())
                .isEmpty()) {

                Customer customer =
                        new Customer();

                customer.setUser(user);
                customer.setFullName(fullName);
                customer.setPhone(phone);
                customer.setAddress(address);

                customerRepository.save(customer);

                System.out.println(
                        "BankEase customer profile created: "
                                + email
                );
        }
        }
}
