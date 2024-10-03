import React, { useState, useEffect } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faBars } from "@fortawesome/free-solid-svg-icons";
import { useLocation } from "react-router-dom"; // นำเข้า useLocation

const Navbar = ({ toggleSidebar }) => {
  const [email, setEmail] = useState("");
  const location = useLocation(); // ใช้สำหรับตรวจสอบเส้นทางปัจจุบัน

  // ดึงค่า email จาก localStorage เมื่อคอมโพเนนต์ถูกโหลด
  useEffect(() => {
    const storedEmail = localStorage.getItem("adminEmail");
    if (storedEmail) {
      setEmail(storedEmail);
    }
  }, []);

  // ฟังก์ชันตรวจสอบเมนูที่เลือกจากเส้นทางปัจจุบัน
  const getMenuTitle = () => {
    switch (location.pathname) {
      case "/dashboard":
        return "Dashboard";
      case "/users":
        return "User Management";
      case "/foodmenu":
        return "FoodMenu Management";
      case "/foodcategories":
        return "Ingredients Management";
      case "/ingredients":
        return "Ingredient Management";
      case "/disease":
        return "Disease Management";
      case "/settings":
        return "Settings";
      default:
        return "Dashboard";
    }
  };

  return (
    <nav className="bg-white shadow-lg rounded-xl mx-4 my-4 p-4">
      <div className="container mx-auto flex justify-start items-center">
        {/* Hamburger Icon */}
        <button
          onClick={toggleSidebar}
          className="text-gray-600 focus:outline-none mr-4"
        >
          <FontAwesomeIcon icon={faBars} className="w-6 h-6" />
        </button>

        {/* Show current menu title */}
        <div className="text-2xl font-bold text-gray-700">{getMenuTitle()}</div>

        {/* Profile Section */}
        <div className="flex items-center space-x-4 ml-auto">
          {/* Profile Picture */}
          <div className="relative">
            <img
              className="w-10 h-10 rounded-full object-cover border-2 border-white shadow-lg cursor-pointer transition duration-300 hover:scale-110"
              src="../../../public/image/logo6.png" // Replace with actual profile picture URL
              alt="User Profile"
            />
          </div>

          {/* Display email from localStorage */}
          <div className="text-gray-700 text-sm">
            {email || "admin@email.com"}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
