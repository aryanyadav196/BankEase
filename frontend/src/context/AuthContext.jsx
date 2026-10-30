import {
    useEffect,
    useState,
} from "react";
import { AuthContext } from "./auth-context";

function normalizeAuth(value) {
    if (!value || typeof value !== "object" || !value.token) {
        return null;
    }

    const normalizedRole = String(value.role || "")
        .replace(/^ROLE_/i, "")
        .toUpperCase();

    if (!["CUSTOMER", "EMPLOYEE", "ADMIN"].includes(normalizedRole)) {
        return null;
    }

    return {
        ...value,
        role: normalizedRole,
    };
}

export function AuthProvider({ children }) {

    function readStoredAuth() {

        const storedAuth =
            localStorage.getItem("bankease_auth");

        if (!storedAuth) {
            return null;
        }

        try {
            return normalizeAuth(JSON.parse(storedAuth));
        } catch {
            localStorage.removeItem("bankease_auth");
            return null;
        }
    }

    const [auth, setAuth] = useState(() => {
        return readStoredAuth();
    });

    useEffect(() => {

        if (auth) {
            localStorage.setItem(
                "bankease_auth",
                JSON.stringify(auth)
            );
        } else {
            localStorage.removeItem(
                "bankease_auth"
            );
        }

    }, [auth]);

    function login(loginResponse) {
        const normalizedAuth = normalizeAuth(loginResponse);
        setAuth(normalizedAuth);

        if (normalizedAuth) {
            localStorage.setItem("bankease_auth", JSON.stringify(normalizedAuth));
        }
    }

    function logout() {
        setAuth(null);
        localStorage.removeItem("bankease_auth");
    }

    return (
        <AuthContext.Provider
            value={{
                auth,
                login,
                logout,
                isAuthenticated: Boolean(auth),
            }}
        >
            {children}
        </AuthContext.Provider>
    );
}

