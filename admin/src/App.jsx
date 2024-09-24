import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import LoginAdmin from "./components/login/login_admin.jsx";
import DashboardPage from "./components/dashboard/dashboard_page.jsx";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LoginAdmin />} />
        <Route path="/dashboard" element={<DashboardPage />} />
      </Routes>
    </Router>
  );
}

export default App;
