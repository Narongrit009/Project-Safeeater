import React, { useState, useEffect } from "react";
import axios from "axios";
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
  const [dashboardData, setDashboardData] = useState({
    total_users: 0,
    total_food_menu: 0,
    total_ingredients: 0,
    total_diseases: 0,
  });
  const [pieData, setPieData] = useState([]);
  const [barData, setBarData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isSidebarOpen, setSidebarOpen] = useState(true);

  const toggleSidebar = () => {
    setSidebarOpen(!isSidebarOpen);
  };

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const dashboardResponse = await axios.get(
          `${import.meta.env.VITE_API_URL_DASHBOARD_DATA}`
        );
        const pieResponse = await axios.get(
          `${import.meta.env.VITE_API_URL_PIE_CHART_DATA}`
        );
        const barResponse = await axios.get(
          `${import.meta.env.VITE_API_URL_BAR_CHART_DATA}`
        );

        setDashboardData(dashboardResponse.data.data);
        setPieData(pieResponse.data.data);
        setBarData(barResponse.data.data);
        setLoading(false);
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const generateGradientColors = (count) => {
    const colors = [];
    const step = 360 / count;
    for (let i = 0; i < count; i++) {
      const hue = Math.floor(step * i);
      colors.push(`hsl(${hue}, 70%, 50%)`);
    }
    return colors;
  };

  const pieChartData = {
    labels: pieData.map((item) => item.category_name),
    datasets: [
      {
        label: "จำนวนเมนู",
        data: pieData.map((item) => item.total_menus),
        backgroundColor: generateGradientColors(pieData.length),
        hoverBackgroundColor: generateGradientColors(pieData.length),
      },
    ],
  };

  const barChartData = {
    labels: barData.map((item) => item.condition_name),
    datasets: [
      {
        label: "จำนวนผู้ใช้ที่มีโรคประจำตัว",
        data: barData.map((item) => item.total_users),
        backgroundColor: "#36A2EB",
      },
    ],
  };

  const chartOptions = {
    maintainAspectRatio: false,
    responsive: true,
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen text-2xl">
        กำลังโหลด...
      </div>
    );
  }

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-100 to-gray-300">
      <Sidebar isSidebarOpen={isSidebarOpen} />
      <div className="flex-1">
        <Navbar toggleSidebar={toggleSidebar} />

        <div className="p-8 space-y-8">
          <header className="flex justify-between items-center mb-10">
            <h1 className="text-4xl font-extrabold text-gray-900 tracking-tight">
              ยินดีต้อนรับสู่แดชบอร์ด 👋
            </h1>
          </header>

          {/* Cards Section */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="bg-gradient-to-r from-blue-500 to-indigo-500 p-6 rounded-2xl shadow-lg transition-transform duration-300 transform hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white font-semibold">จำนวนผู้ใช้</h3>
              <p className="text-5xl font-bold text-white">
                {dashboardData.total_users}
              </p>
            </div>
            <div className="bg-gradient-to-r from-purple-500 to-pink-500 p-6 rounded-2xl shadow-lg transition-transform duration-300 transform hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white font-semibold">
                จำนวนเมนูอาหาร
              </h3>
              <p className="text-5xl font-bold text-white">
                {dashboardData.total_food_menu}
              </p>
            </div>
            <div className="bg-gradient-to-r from-yellow-500 to-orange-500 p-6 rounded-2xl shadow-lg transition-transform duration-300 transform hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white font-semibold">
                จำนวนวัตถุดิบ
              </h3>
              <p className="text-5xl font-bold text-white">
                {dashboardData.total_ingredients}
              </p>
            </div>
            <div className="bg-gradient-to-r from-red-500 to-pink-500 p-6 rounded-2xl shadow-lg transition-transform duration-300 transform hover:scale-105 hover:shadow-2xl">
              <h3 className="text-lg text-white font-semibold">จำนวนโรค</h3>
              <p className="text-5xl font-bold text-white">
                {dashboardData.total_diseases}
              </p>
            </div>
          </div>

          {/* Graph Section */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="bg-white bg-opacity-60 p-8 rounded-2xl shadow-lg backdrop-blur-lg transition-transform duration-500 transform hover:scale-105 hover:shadow-2xl">
              <h3 className="text-3xl font-semibold text-gray-800 mb-6">
                สัดส่วนเมนูอาหารในแต่ละหมวดหมู่
              </h3>
              <div className="w-full h-96">
                <Pie data={pieChartData} options={chartOptions} />
              </div>
            </div>
            <div className="bg-white bg-opacity-60 p-8 rounded-2xl shadow-lg backdrop-blur-lg transition-transform duration-500 transform hover:scale-105 hover:shadow-2xl">
              <h3 className="text-3xl font-semibold text-gray-800 mb-6">
                จำนวนผู้ใช้ที่มีโรคประจำตัว
              </h3>
              <div className="w-full h-96">
                <Bar data={barChartData} options={chartOptions} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
