import React, { useEffect, useState } from "react";
import {
  BrowserRouter as Router,
  Route,
  Routes,
  Navigate,
} from "react-router-dom";
import LoginAdmin from "./components/login/login_admin.jsx";
import DashboardPage from "./components/dashboard/dashboard_page.jsx";
import Users from "./components/dashboard/user/users.jsx"; // นำเข้า Users component
import FoodMenuByCategory from "./components/dashboard/table/foodmenu/food_menu.jsx"; // นำเข้า Users component
import Disease from "./components/dashboard/table/disease/disease.jsx"; // นำเข้า Users component
import FoodCategories from "./components/dashboard/table/categories/foodcategories.jsx"; // นำเข้า Users component
import Ingredients from "./components/dashboard/table/ingredient/ingredient.jsx"; // นำเข้า Users component

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
        <Route
          path="/users"
          element={isAuthenticated ? <Users /> : <Navigate to="/" />}
        />
        <Route
          path="/foodmenu"
          element={
            isAuthenticated ? <FoodMenuByCategory /> : <Navigate to="/" />
          }
        />
        <Route
          path="/disease"
          element={isAuthenticated ? <Disease /> : <Navigate to="/" />}
        />
        <Route
          path="/foodcategories"
          element={isAuthenticated ? <FoodCategories /> : <Navigate to="/" />}
        />
        <Route
          path="/ingredients"
          element={isAuthenticated ? <Ingredients /> : <Navigate to="/" />}
        />
      </Routes>
    </Router>
  );
}

export default App;
