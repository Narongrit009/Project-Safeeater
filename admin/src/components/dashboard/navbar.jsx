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
        return "แดชบอร์ด";
      case "/users":
        return "การจัดการผู้ใช้";
      case "/foodmenu":
        return "การจัดการเมนูอาหาร";
      case "/foodcategories":
        return "การจัดการประเภทอาหาร";
      case "/ingredients":
        return "การจัดการวัตถุดิบ";
      case "/disease":
        return "การจัดการโรค";
      case "/settings":
        return "การตั้งค่า";
      default:
        return "แดชบอร์ด";
    }
  };

  return (
    <nav className="bg-white shadow-lg rounded-xl mx-4 my-4 p-4">
      <div className="container mx-auto flex justify-start items-center">
        {/* ไอคอนแฮมเบอร์เกอร์ */}
        <button
          onClick={toggleSidebar}
          className="text-gray-600 focus:outline-none mr-4"
        >
          <FontAwesomeIcon icon={faBars} className="w-6 h-6" />
        </button>

        {/* แสดงชื่อเมนูปัจจุบัน */}
        <div className="text-2xl font-bold text-gray-700">{getMenuTitle()}</div>

        {/* ส่วนของโปรไฟล์ */}
        <div className="flex items-center space-x-4 ml-auto">
          {/* รูปโปรไฟล์ */}
          <div className="relative">
            <img
              className="w-10 h-10 rounded-full object-cover border-2 border-white shadow-lg cursor-pointer transition duration-300 hover:scale-110"
              src="../../../public/image/logo6.png" // แทนที่ด้วย URL รูปโปรไฟล์จริง
              alt="โปรไฟล์ผู้ใช้"
            />
          </div>

          {/* แสดงอีเมลจาก localStorage */}
          <div className="text-gray-700 text-sm">
            {email || "admin@email.com"}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
