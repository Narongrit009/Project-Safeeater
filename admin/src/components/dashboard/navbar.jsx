import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faBars } from "@fortawesome/free-solid-svg-icons";

const Navbar = ({ toggleSidebar }) => {
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

        {/* Logo or Title */}
        <div className="text-2xl font-bold text-gray-700">Dashboard</div>

        {/* Profile Section */}
        <div className="flex items-center space-x-4 ml-auto">
          {/* Profile Picture */}
          <div className="relative">
            <img
              className="w-10 h-10 rounded-full object-cover border-2 border-white shadow-lg cursor-pointer transition duration-300 hover:scale-110"
              src="https://via.placeholder.com/150" // Replace with actual profile picture URL
              alt="User Profile"
            />
          </div>
          <div className="text-gray-700 text-sm">user@example.com</div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
