import React from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faUser,
  faChartPie,
  faShoppingCart,
  faCog,
  faSignOutAlt,
} from "@fortawesome/free-solid-svg-icons";

const Sidebar = () => {
  return (
    <div className="h-screen bg-blue-500 text-white w-64 p-6">
      <div className="flex items-center space-x-4 mb-8">
        <div className="w-8 h-8 bg-white rounded-full"></div>
        <h2 className="text-xl font-semibold">Team 1</h2>
      </div>
      <nav className="mt-10">
        <ul>
          <li className="mb-4">
            <Link
              to="/dashboard"
              className="block py-2.5 px-4 rounded hover:bg-blue-600 transition duration-200 flex items-center space-x-4"
            >
              <FontAwesomeIcon icon={faChartPie} />
              <span>Dashboard</span>
            </Link>
          </li>
          <li className="mb-4">
            <Link
              to="/user"
              className="block py-2.5 px-4 rounded hover:bg-blue-600 transition duration-200 flex items-center space-x-4"
            >
              <FontAwesomeIcon icon={faUser} />
              <span>User</span>
            </Link>
          </li>
          <li className="mb-4">
            <Link
              to="/product"
              className="block py-2.5 px-4 rounded hover:bg-blue-600 transition duration-200 flex items-center space-x-4"
            >
              <FontAwesomeIcon icon={faShoppingCart} />
              <span>Product</span>
            </Link>
          </li>
          <li className="mb-4">
            <Link
              to="/settings"
              className="block py-2.5 px-4 rounded hover:bg-blue-600 transition duration-200 flex items-center space-x-4"
            >
              <FontAwesomeIcon icon={faCog} />
              <span>Settings</span>
            </Link>
          </li>
          <li className="mb-4">
            <Link
              to="/logout"
              className="block py-2.5 px-4 rounded hover:bg-blue-600 transition duration-200 flex items-center space-x-4"
            >
              <FontAwesomeIcon icon={faSignOutAlt} />
              <span>Logout</span>
            </Link>
          </li>
        </ul>
      </nav>
    </div>
  );
};

export default Sidebar;
