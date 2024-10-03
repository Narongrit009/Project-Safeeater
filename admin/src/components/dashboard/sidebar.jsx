import React, { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import Swal from "sweetalert2";
import {
  faUser,
  faChartPie,
  faTable,
  faCog,
  faSignOutAlt,
  faChevronDown,
  faChevronUp,
} from "@fortawesome/free-solid-svg-icons";

const Sidebar = ({ isSidebarOpen }) => {
  const navigate = useNavigate();
  const location = useLocation(); // Use this to determine the current route
  const [isTableMenuOpen, setIsTableMenuOpen] = useState(false);

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
        localStorage.clear();
        Swal.fire(
          "ออกจากระบบแล้ว!",
          "คุณได้ออกจากระบบเรียบร้อยแล้ว.",
          "success"
        ).then(() => {
          window.location.reload();
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
          {isSidebarOpen && (
            <div className="flex items-center space-x-3">
              <img
                src="../../../public/image/logo5.png"
                alt="Logo"
                className="w-10 h-10 rounded-full shadow-md hover:shadow-lg transition-shadow duration-300"
              />
              <div className="text-2xl font-light text-white tracking-wider hover:tracking-wide transition-all duration-300">
                Admin SafeEater
              </div>
            </div>
          )}
        </div>

        {/* Sidebar Menu */}
        <nav>
          <ul>
            <li className="mb-4">
              <Link
                to="/dashboard"
                className={`flex items-center space-x-4 py-2.5 px-4 rounded-lg transition duration-300 transform hover:scale-105 ${
                  location.pathname === "/dashboard"
                    ? "bg-purple-500 text-white shadow-lg"
                    : "bg-gradient-to-r from-transparent to-transparent hover:from-purple-400 hover:to-indigo-500 hover:text-white hover:shadow-lg"
                }`}
              >
                <FontAwesomeIcon icon={faChartPie} />
                <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                  Dashboard
                </span>
              </Link>
            </li>
            <li className="mb-4">
              <Link
                to="/users"
                className={`flex items-center space-x-4 py-2.5 px-4 rounded-lg transition duration-300 transform hover:scale-105 ${
                  location.pathname === "/users"
                    ? "bg-green-500 text-white shadow-lg"
                    : "bg-gradient-to-r from-transparent to-transparent hover:from-green-400 hover:to-teal-500 hover:text-white hover:shadow-lg"
                }`}
              >
                <FontAwesomeIcon icon={faUser} />
                <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                  User
                </span>
              </Link>
            </li>
            <li className="mb-4">
              {/* Menu "Table" */}
              <button
                onClick={() => setIsTableMenuOpen(!isTableMenuOpen)}
                className={`flex items-center justify-between space-x-4 py-2.5 px-4 w-full rounded-lg transition duration-300 transform hover:scale-105 ${
                  location.pathname.includes("/table") ||
                  location.pathname.includes("/foodmenu") ||
                  location.pathname.includes("/ingredients") ||
                  location.pathname.includes("/disease") ||
                  location.pathname.includes("/foodcategories")
                    ? "bg-gradient-to-r from-yellow-500 to-yellow-600 text-white shadow-lg"
                    : "bg-gradient-to-r from-transparent to-transparent hover:from-yellow-300 hover:to-yellow-500 hover:text-white hover:shadow-md"
                }`}
              >
                <div className="flex items-center space-x-4">
                  <FontAwesomeIcon icon={faTable} />
                  <span className={`${isSidebarOpen ? "block" : "hidden"}`}>
                    Table
                  </span>
                </div>
                {isSidebarOpen && (
                  <FontAwesomeIcon
                    icon={isTableMenuOpen ? faChevronUp : faChevronDown}
                    className="ml-auto"
                  />
                )}
              </button>

              {/* Submenu of Table */}
              {(isTableMenuOpen ||
                location.pathname.includes("/table") ||
                location.pathname.includes("/foodmenu") ||
                location.pathname.includes("/ingredients") ||
                location.pathname.includes("/disease") ||
                location.pathname.includes("/foodcategories")) &&
                isSidebarOpen && (
                  <ul className="ml-4 mt-2 space-y-2 border-l-4 border-yellow-400 pl-4">
                    <li className="mb-2">
                      <Link
                        to="/foodmenu"
                        className={`flex items-center space-x-3 py-2 px-3 rounded-lg transition duration-300 ${
                          location.pathname === "/foodmenu"
                            ? "bg-gradient-to-r from-yellow-500 to-orange-500 text-white shadow-inner"
                            : "hover:bg-gradient-to-r hover:from-yellow-400 hover:to-orange-400 hover:text-white"
                        }`}
                      >
                        <span>🍽️</span>
                        <span>Food Menu</span>
                      </Link>
                    </li>
                    <li className="mb-2">
                      <Link
                        to="/foodcategories"
                        className={`flex items-center space-x-3 py-2 px-3 rounded-lg transition duration-300 ${
                          location.pathname === "/foodcategories"
                            ? "bg-gradient-to-r from-purple-500 to-purple-600 text-white shadow-inner"
                            : "hover:bg-gradient-to-r hover:from-purple-400 hover:to-purple-500 hover:text-white"
                        }`}
                      >
                        <span>📂</span>
                        <span>Food Categories</span>
                      </Link>
                    </li>
                    <li className="mb-2">
                      <Link
                        to="/ingredients"
                        className={`flex items-center space-x-3 py-2 px-3 rounded-lg transition duration-300 ${
                          location.pathname === "/ingredients"
                            ? "bg-gradient-to-r from-green-400 to-teal-500 text-white shadow-inner"
                            : "hover:bg-gradient-to-r hover:from-green-300 hover:to-teal-400 hover:text-white"
                        }`}
                      >
                        <span>🌿</span>
                        <span>Ingredient</span>
                      </Link>
                    </li>
                    <li className="mb-2">
                      <Link
                        to="/disease"
                        className={`flex items-center space-x-3 py-2 px-3 rounded-lg transition duration-300 ${
                          location.pathname === "/disease"
                            ? "bg-gradient-to-r from-red-400 to-pink-500 text-white shadow-inner"
                            : "hover:bg-gradient-to-r hover:from-red-300 hover:to-pink-400 hover:text-white"
                        }`}
                      >
                        <span>🩺</span>
                        <span>Disease</span>
                      </Link>
                    </li>
                  </ul>
                )}
            </li>

            <li className="mb-4">
              <Link
                to="/settings"
                className={`flex items-center space-x-4 py-2.5 px-4 rounded-lg transition duration-300 transform hover:scale-105 ${
                  location.pathname === "/settings"
                    ? "bg-pink-500 text-white shadow-lg"
                    : "bg-gradient-to-r from-transparent to-transparent hover:from-pink-400 hover:to-red-500 hover:text-white hover:shadow-lg"
                }`}
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
