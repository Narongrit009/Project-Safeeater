import React from "react";
import { Link, useNavigate } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import Swal from "sweetalert2"; // นำเข้า SweetAlert2
import {
  faUser,
  faChartPie,
  faShoppingCart,
  faCog,
  faSignOutAlt,
} from "@fortawesome/free-solid-svg-icons";

const Sidebar = ({ isSidebarOpen }) => {
  const navigate = useNavigate();

  const handleLogout = () => {
    Swal.fire({
      title: "คุณต้องการออกจากระบบหรือไม่?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#d33",
      confirmButtonText: "ออกจากระบบ",
      cancelButtonText: "ยกเลิก",
    }).then((result) => {
      if (result.isConfirmed) {
        // ลบข้อมูลใน LocalStorage
        localStorage.clear();

        // แสดงข้อความสำเร็จ
        Swal.fire(
          "ออกจากระบบแล้ว!",
          "คุณได้ออกจากระบบเรียบร้อยแล้ว.",
          "success"
        ).then(() => {
          // รีเฟรชหน้าเพื่อนำไปยังหน้า Login
          window.location.reload(); // รีเฟรชหน้าเว็บ
        });
      }
    });
  };

  return (
    <div
      className={`${
        isSidebarOpen ? "w-64" : "w-20"
      } min-h-screen bg-gradient-to-r from-indigo-600 to-blue-500 text-white p-4 shadow-xl transition-all duration-300 ease-in-out flex flex-col justify-between`}
    >
      {/* Sidebar Header */}
      <div>
        <div className="flex items-center justify-center mb-10">
          <div
            className={`${
              isSidebarOpen ? "block" : "hidden"
            } text-2xl font-bold`}
          >
            My Dashboard
          </div>
        </div>

        {/* Sidebar Menu */}
        <nav>
          <ul>
            <li className="mb-4">
              <Link
                to="/dashboard"
                className="flex items-center space-x-4 py-2.5 px-4 rounded-lg bg-gradient-to-r from-transparent to-transparent hover:from-purple-400 hover:to-indigo-500 hover:text-white hover:shadow-lg transition duration-300 transform hover:scale-105"
              >
                <FontAwesomeIcon icon={faChartPie} />
                <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                  Dashboard
                </span>
              </Link>
            </li>
            <li className="mb-4">
              <Link
                to="/user"
                className="flex items-center space-x-4 py-2.5 px-4 rounded-lg bg-gradient-to-r from-transparent to-transparent hover:from-green-400 hover:to-teal-500 hover:text-white hover:shadow-lg transition duration-300 transform hover:scale-105"
              >
                <FontAwesomeIcon icon={faUser} />
                <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                  User
                </span>
              </Link>
            </li>
            <li className="mb-4">
              <Link
                to="/product"
                className="flex items-center space-x-4 py-2.5 px-4 rounded-lg bg-gradient-to-r from-transparent to-transparent hover:from-yellow-400 hover:to-orange-500 hover:text-white hover:shadow-lg transition duration-300 transform hover:scale-105"
              >
                <FontAwesomeIcon icon={faShoppingCart} />
                <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                  Product
                </span>
              </Link>
            </li>
            <li className="mb-4">
              <Link
                to="/settings"
                className="flex items-center space-x-4 py-2.5 px-4 rounded-lg bg-gradient-to-r from-transparent to-transparent hover:from-pink-400 hover:to-red-500 hover:text-white hover:shadow-lg transition duration-300 transform hover:scale-105"
              >
                <FontAwesomeIcon icon={faCog} />
                <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                  Settings
                </span>
              </Link>
            </li>
            <li className="mb-4">
              <button
                onClick={handleLogout}
                className="w-full flex items-center space-x-4 py-2.5 px-4 rounded-lg bg-gradient-to-r from-transparent to-transparent hover:from-red-400 hover:to-red-600 hover:text-white hover:shadow-lg transition duration-300 transform hover:scale-105"
              >
                <FontAwesomeIcon icon={faSignOutAlt} />
                <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                  Logout
                </span>
              </button>
            </li>
          </ul>
        </nav>
      </div>

      {/* Sidebar Footer */}
      <div
        className={`flex items-center justify-center ${
          isSidebarOpen ? "block" : "hidden"
        }`}
      >
        <p className="text-sm">© 2024 Dashboard SafeEater v0.1</p>
      </div>
    </div>
  );
};

export default Sidebar;
