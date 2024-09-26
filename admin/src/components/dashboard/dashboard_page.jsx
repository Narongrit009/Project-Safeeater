import React, { useState } from "react"; // นำเข้า React เพียงครั้งเดียว
import Sidebar from "./sidebar";
import Navbar from "./navbar";
import { Bar, Pie } from "react-chartjs-2";
import {
  Chart as ChartJS,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend,
  ArcElement,
} from "chart.js";

ChartJS.register(
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Legend,
  ArcElement
);

const DashboardPage = () => {
  const pieData = {
    labels: ["America", "Asia", "Europe", "Africa"],
    datasets: [
      {
        label: "Current Visits",
        data: [43.8, 31.3, 18.8, 6.3],
        backgroundColor: ["#FF6384", "#36A2EB", "#FFCE56", "#FF9F40"],
        hoverBackgroundColor: ["#FF6384", "#36A2EB", "#FFCE56", "#FF9F40"],
      },
    ],
  };

  const barData = {
    labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep"],
    datasets: [
      {
        label: "Team A",
        data: [40, 30, 20, 50, 60, 70, 40, 50, 60],
        backgroundColor: "#36A2EB",
      },
      {
        label: "Team B",
        data: [60, 50, 70, 40, 30, 20, 60, 70, 80],
        backgroundColor: "#FF6384",
      },
    ],
  };

  const options = {
    maintainAspectRatio: false,
    responsive: true,
  };

  const [isSidebarOpen, setSidebarOpen] = useState(true);

  const toggleSidebar = () => {
    setSidebarOpen(!isSidebarOpen);
  };

  return (
    <div className="min-h-screen flex bg-gray-50">
      <Sidebar isSidebarOpen={isSidebarOpen} />
      <div className="flex-1">
        <Navbar toggleSidebar={toggleSidebar} />

        <div className="p-8 space-y-8">
          <header className="flex justify-between items-center mb-8">
            <h1 className="text-4xl font-bold text-gray-900">Hi, Welcome 👋</h1>
          </header>

          {/* Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="bg-gradient-to-r from-blue-500 to-indigo-500 p-6 rounded-xl shadow-xl transform transition-all duration-500 hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white">Weekly Sales</h3>
              <p className="text-4xl font-bold text-white">714k</p>
              <p className="text-lg text-green-200">+2.6%</p>
            </div>
            <div className="bg-gradient-to-r from-purple-500 to-pink-500 p-6 rounded-xl shadow-xl transform transition-all duration-500 hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white">New Users</h3>
              <p className="text-4xl font-bold text-white">1.35m</p>
              <p className="text-lg text-red-200">-0.1%</p>
            </div>
            <div className="bg-gradient-to-r from-yellow-500 to-orange-500 p-6 rounded-xl shadow-xl transform transition-all duration-500 hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white">Purchase Orders</h3>
              <p className="text-4xl font-bold text-white">1.72m</p>
              <p className="text-lg text-green-200">+2.8%</p>
            </div>
            <div className="bg-gradient-to-r from-red-500 to-pink-500 p-6 rounded-xl shadow-xl transform transition-all duration-500 hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white">Messages</h3>
              <p className="text-4xl font-bold text-white">234</p>
              <p className="text-lg text-green-200">+3.6%</p>
            </div>
          </div>

          {/* Graph Section */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="bg-white bg-opacity-60 p-8 rounded-xl shadow-lg backdrop-blur-lg transform transition-all duration-500 hover:scale-105 hover:shadow-2xl">
              <h3 className="text-2xl font-semibold text-gray-800 mb-6">
                Current Visits
              </h3>
              <div className="w-full h-96">
                <Pie data={pieData} options={options} />
              </div>
            </div>
            <div className="bg-white bg-opacity-60 p-8 rounded-xl shadow-lg backdrop-blur-lg transform transition-all duration-500 hover:scale-105 hover:shadow-2xl">
              <h3 className="text-2xl font-semibold text-gray-800 mb-6">
                Website Visits
              </h3>
              <div className="w-full h-96">
                <Bar data={barData} options={options} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
