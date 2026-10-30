import CustomerDashboard from "./pages/customer/CustomerDashboard";
import CustomerServiceRequests from "./pages/customer/CustomerServiceRequests";
import EmployeeDashboard from "./pages/employee/EmployeeDashboard";
import AdminDashboard from "./pages/admin/AdminDashboard";
import {
    BrowserRouter,
    Navigate,
    Route,
    Routes,
} from "react-router-dom";

import { AuthProvider } from "./context/AuthContext";
import { useAuth } from "./context/useAuth";
import Login from "./pages/auth/Login";
import CustomerRegister from "./pages/auth/CustomerRegister";
import StaffRegister from "./pages/auth/StaffRegister";
import ExperimentsLab from "./pages/lab/ExperimentsLab";

function normalizeRole(value) {
    return String(value || "")
        .replace(/^ROLE_/i, "")
        .toUpperCase();
}

function RoleRoute({ role, children }) {
    const { auth } = useAuth();
    const expectedRole = normalizeRole(role);
    const currentRole = normalizeRole(auth?.role);

    if (!auth?.token) {
        return <Navigate to={`/login?role=${expectedRole.toLowerCase()}`} replace />;
    }

    if (currentRole !== expectedRole) {
        return <Navigate to={`/${currentRole.toLowerCase()}`} replace />;
    }

    return children;
}

function PublicRoute({ children }) {
    const { auth } = useAuth();

    if (auth?.token) {
        const role = normalizeRole(auth.role);
        return <Navigate to={`/${role.toLowerCase()}`} replace />;
    }

    return children;
}

function App() {

    return (
        <BrowserRouter>

            <AuthProvider>

                <Routes>

                    <Route
                        path="/login"
                        element={<PublicRoute><Login /></PublicRoute>}
                    />

                    <Route
                        path="/customer/login"
                        element={<Navigate to="/login?role=customer" replace />}
                    />

                    <Route
                        path="/customer/register"
                        element={<CustomerRegister />}
                    />

                    <Route
                        path="/employee/login"
                        element={<Navigate to="/login?role=employee" replace />}
                    />

                    <Route
                        path="/employee/register"
                        element={<StaffRegister role="EMPLOYEE" />}
                    />

                    <Route
                        path="/admin/login"
                        element={<Navigate to="/login?role=admin" replace />}
                    />

                    <Route
                        path="/admin/register"
                        element={<StaffRegister role="ADMIN" />}
                    />

                    <Route
                        path="/experiments"
                        element={<ExperimentsLab />}
                    />

                    <Route
                        path="/customer"
                        element={<RoleRoute role="CUSTOMER"><CustomerDashboard /></RoleRoute>}
                    />

                    <Route
                        path="/customer/service-requests"
                        element={<RoleRoute role="CUSTOMER"><CustomerServiceRequests /></RoleRoute>}
                    />

                    <Route
                        path="/customer/service-requests/new"
                        element={<RoleRoute role="CUSTOMER"><CustomerServiceRequests /></RoleRoute>}
                    />

                    <Route
                        path="/employee"
                        element={<RoleRoute role="EMPLOYEE"><EmployeeDashboard /></RoleRoute>}
                    />

                    <Route
                        path="/admin"
                        element={<RoleRoute role="ADMIN"><AdminDashboard /></RoleRoute>}
                    />

                    <Route
                        path="/"
                        element={
                            <Navigate
                                to="/login"
                                replace
                            />
                        }
                    />

                    <Route
                        path="*"
                        element={
                            <Navigate
                                to="/login"
                                replace
                            />
                        }
                    />

                </Routes>

            </AuthProvider>

        </BrowserRouter>
    );
}

export default App;
