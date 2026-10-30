import { Link } from "react-router-dom";
import "./ExperimentsLab.css";

const experiments = [
    {
        number: "01",
        name: "HTML5/CSS3 forms, tables and lists",
        status: "Partially evidenced",
        tone: "partial",
        description: "Review the registration, login, dashboard forms, responsive layouts, and list-based operational views already used by BankEase.",
        links: [
            { label: "Customer registration", to: "/customer/register" },
            { label: "Login screen", to: "/login" },
        ],
    },
    {
        number: "02",
        name: "REST APIs, CRUD operations and Postman",
        status: "Partially evidenced",
        tone: "partial",
        description: "Use the Spring REST endpoints for accounts, transactions, service requests, and administration. A Postman collection is planned.",
        links: [],
    },
    {
        number: "03",
        name: "React components, JSX and static data",
        status: "Implemented in app",
        tone: "ready",
        description: "Inspect the React component tree, JSX dashboards, route composition, and UI data mapping that power the BankEase experience.",
        links: [
            { label: "Customer workspace", to: "/customer" },
            { label: "Operations workspace", to: "/employee" },
        ],
    },
    {
        number: "04",
        name: "React Hooks, Context API, form handling and validation",
        status: "Implemented in app",
        tone: "ready",
        description: "Demonstrate AuthContext, useAuth, controlled inputs, hooks, loading states, form validation, and error handling through the existing screens.",
        links: [
            { label: "Sign-in flow", to: "/login" },
            { label: "Customer registration", to: "/customer/register" },
        ],
    },
    {
        number: "05",
        name: "Kotlin data types, collections, OOP and inheritance",
        status: "Planned module",
        tone: "planned",
        description: "A standalone Kotlin/JVM lab now contains examples of data types, collections, classes, objects, inheritance, and overriding. Local execution remains pending Gradle availability.",
        links: [{ label: "Kotlin Lab instructions", to: "#kotlin-lab" }],
    },
    {
        number: "06",
        name: "Kotlin exception handling and map/filter/reduce",
        status: "Planned module",
        tone: "planned",
        description: "The Kotlin lab contains try-catch-finally, throw, a custom exception, and map/filter/reduce examples. Local execution remains pending Gradle availability.",
        links: [{ label: "Kotlin Lab instructions", to: "#kotlin-lab" }],
    },
    {
        number: "07",
        name: "Spring Boot REST CRUD APIs",
        status: "Implemented in backend",
        tone: "ready",
        description: "Demonstrate controller, service, repository, DTO, validation, persistence, account, transaction, and service-request flows from the existing backend.",
        links: [
            { label: "Employee operations", to: "/employee" },
            { label: "Admin control centre", to: "/admin" },
        ],
    },
    {
        number: "08",
        name: "JWT/OAuth2 authentication and API testing",
        status: "JWT implemented; OAuth2 planned",
        tone: "partial",
        description: "The current application demonstrates JWT authentication and role authorization. OAuth2 and a repeatable Postman test collection are planned.",
        links: [
            { label: "Open sign-in", to: "/login" },
            { label: "Admin controls", to: "/admin" },
        ],
    },
    {
        number: "09",
        name: "Spring Boot application deployment",
        status: "Planned deployment evidence",
        tone: "planned",
        description: "The backend runs locally through Maven. Production packaging, deployment configuration, and hosting evidence are planned and not available here yet.",
        links: [],
    },
    {
        number: "10",
        name: "Flutter Hello App, widgets and layouts",
        status: "Planned module",
        tone: "planned",
        description: "A separate Flutter application will demonstrate a Hello App, Material widgets, layouts, and basic navigation. It is not available yet.",
        links: [],
    },
    {
        number: "11",
        name: "Firebase Authentication and Cloud Firestore",
        status: "Planned isolated demo",
        tone: "planned",
        description: "A separate safe demo will use synthetic accounts and records only. It will not connect to BankEase JWT authentication, MySQL, or banking data.",
        links: [],
    },
];

function ExperimentsLab() {
    return (
        <div className="lab-app">
            <header className="lab-topbar">
                <Link className="lab-brand" to="/">
                    <span className="lab-brand-mark">B</span>
                    <span>
                        <strong>BankEase</strong>
                        <small>Experiments lab</small>
                    </span>
                </Link>
                <nav className="lab-topnav" aria-label="Lab navigation">
                    <a href="#experiments">All experiments</a>
                    <a href="#next">Next steps</a>
                    <Link to="/login">Sign in</Link>
                </nav>
            </header>

            <main className="lab-main">
                <section className="lab-hero">
                    <div>
                        <span className="lab-kicker">UNIFIED PRESENTATION HUB</span>
                        <h1>One place to walk through BankEase.</h1>
                        <p>Explore the 11 Web and Mobile Application Development experiments, with direct links to working BankEase flows and clear markers for planned demonstrations.</p>
                    </div>
                    <div className="lab-hero-card">
                        <span>EXPERIMENTS IN VIEW</span>
                        <strong>11</strong>
                        <small>One presentation path</small>
                    </div>
                </section>

                <section className="lab-summary" aria-label="Experiment status summary">
                    <div><strong>3</strong><span>Already evidenced</span></div>
                    <div><strong>3</strong><span>Partially evidenced</span></div>
                    <div><strong>5</strong><span>Planned modules</span></div>
                </section>

                <section className="lab-section" id="experiments">
                    <div className="lab-section-heading">
                        <div>
                            <span className="lab-kicker">THE CURRICULUM</span>
                            <h2>Experiment map</h2>
                        </div>
                        <p>Current status reflects the source-backed audit of this repository.</p>
                    </div>
                    <div className="experiment-grid">
                        {experiments.map((experiment) => (
                            <article className="experiment-card" key={experiment.number}>
                                <div className="experiment-card-top">
                                    <span className="experiment-number">{experiment.number}</span>
                                    <span className={`experiment-status ${experiment.tone}`}>{experiment.status}</span>
                                </div>
                                <h3>{experiment.name}</h3>
                                <p>{experiment.description}</p>
                                {experiment.links.length > 0 && (
                                    <div className="experiment-links">
                                        {experiment.links.map((link) => <Link key={link.to} to={link.to}>{link.label} <span aria-hidden="true">→</span></Link>)}
                                    </div>
                                )}
                            </article>
                        ))}
                    </div>
                </section>

                <section className="lab-next" id="next">
                    <div>
                        <span className="lab-kicker">WHAT COMES NEXT</span>
                        <h2>Keep the application core focused.</h2>
                        <p>Kotlin, Flutter, Firebase, Postman, and deployment demonstrations will be added as separate, documented modules or processes. This page is the presentation entry point; it does not claim those modules are complete.</p>
                    </div>
                    <Link className="lab-primary-action" to="/login">Open BankEase</Link>
                </section>

                <section className="kotlin-instructions" id="kotlin-lab">
                    <div>
                        <span className="lab-kicker">TERMINAL DEMONSTRATION</span>
                        <h2>Kotlin Lab: Experiments 5 and 6</h2>
                        <p>The Kotlin lab is a separate JVM module. It is not a browser launch button and does not connect to BankEase data.</p>
                    </div>
                    <pre><code>{"cd C:\\BankEase\\experiments\\kotlin-lab\ngradle run"}</code></pre>
                    <small>Requires Java 21 and Gradle 8.x or newer. See the module README for concepts, setup, and expected output.</small>
                </section>
            </main>
        </div>
    );
}

export default ExperimentsLab;
