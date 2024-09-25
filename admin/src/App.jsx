import React, { useEffect, useState } from "react";
import {
  BrowserRouter as Router,
  Route,
  Routes,
  Navigate,
} from "react-router-dom";
import LoginAdmin from "./components/login/login_admin.jsx";
import DashboardPage from "./components/dashboard/dashboard_page.jsx";

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // ตรวจสอบสถานะการล็อกอินทุกครั้งที่มีการเปลี่ยนแปลง
  useEffect(() => {
    const adminEmail = localStorage.getItem("adminEmail");
    setIsAuthenticated(!!adminEmail); // ถ้า adminEmail มีค่า ให้ isAuthenticated เป็น true
  }, []);

  return (
    <Router>
      <Routes>
        {/* ตรวจสอบสถานะล็อกอิน */}
        <Route
          path="/"
          element={
            isAuthenticated ? (
              <Navigate to="/dashboard" />
            ) : (
              <LoginAdmin setIsAuthenticated={setIsAuthenticated} />
            )
          }
        />
        {/* ถ้าล็อกอินแล้วให้เข้าถึง Dashboard */}
        <Route
          path="/dashboard"
          element={isAuthenticated ? <DashboardPage /> : <Navigate to="/" />}
        />
      </Routes>
    </Router>
  );
}

export default App;
