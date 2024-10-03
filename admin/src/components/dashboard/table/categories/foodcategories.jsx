import React, { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";
import Swal from "sweetalert2"; // นำเข้า SweetAlert2 สำหรับแสดงข้อความแจ้งเตือน
import FoodCategoriesAdd from "./foodcategories_add.jsx";
import FoodCategoriesEdit from "./foodcategories_edit.jsx";

const FoodCategories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState(""); // สำหรับการค้นหา
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // ฟังก์ชันสลับ Sidebar
  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  // ดึงข้อมูลหมวดหมู่จาก API
  const fetchCategories = async () => {
    try {
      const response = await axios.get(
        `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}`
      );
      setCategories(response.data);
      setLoading(false);
    } catch (err) {
      setError(err);
      setLoading(false);
    }
  };

  // เรียกใช้ fetchCategories เมื่อคอมโพเนนต์ถูกติดตั้ง
  useEffect(() => {
    fetchCategories();
  }, []);

  // จัดการการค้นหา
  const handleSearch = (event) => {
    setSearchTerm(event.target.value);
  };

  // กรองหมวดหมู่ตามการค้นหา
  const filteredCategories = categories.filter((category) =>
    category.category_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // ฟังก์ชันจัดการการลบ
  const handleDelete = (id) => {
    Swal.fire({
      title: "คุณแน่ใจหรือไม่?",
      text: "การกระทำนี้ไม่สามารถยกเลิกได้!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "ใช่, ลบเลย!",
      cancelButtonText: "ยกเลิก",
    }).then((result) => {
      if (result.isConfirmed) {
        // เรียก API เพื่อลบหมวดหมู่
        axios
          .delete(
            `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}?id=${id}`
          )
          .then(() => {
            // อัปเดตรายการหลังจากการลบ
            setCategories(categories.filter((category) => category.id !== id));
            Swal.fire("ลบแล้ว!", "หมวดหมู่ถูกลบเรียบร้อย.", "success");
          })
          .catch((error) => {
            Swal.fire("ผิดพลาด!", "ไม่สามารถลบหมวดหมู่ได้.", "error");
          });
      }
    });
  };

  if (loading) return <div>กำลังโหลด...</div>;
  if (error) return <div>เกิดข้อผิดพลาด: {error.message}</div>;

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-100 to-gray-200">
      {/* Sidebar */}
      <Sidebar isSidebarOpen={isSidebarOpen} />

      {/* Main Content */}
      <div className="flex-1 p-8">
        {/* Navbar */}
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-4xl font-bold text-center mb-8 text-gray-800">
          หมวดหมู่อาหาร
        </h1>

        {/* กล่องค้นหา */}
        <div className="flex justify-between mb-6">
          <input
            type="text"
            placeholder="ค้นหาหมวดหมู่"
            className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-md"
            value={searchTerm}
            onChange={handleSearch}
          />
          <FoodCategoriesAdd onAdd={fetchCategories} />
        </div>

        {/* ตารางหมวดหมู่ */}
        <div className="overflow-x-auto">
          <table className="min-w-full bg-white shadow-md rounded-lg overflow-hidden">
            <thead>
              <tr className="bg-blue-500 text-white">
                <th className="py-3 px-4 text-left">#</th>
                <th className="py-3 px-4 text-left">ชื่อหมวดหมู่</th>
                <th className="py-3 px-4 text-left">รายละเอียด</th>
                <th className="py-3 px-4 text-center">การจัดการ</th>
              </tr>
            </thead>
            <tbody>
              {filteredCategories.map((category, index) => (
                <tr
                  key={category.id}
                  className={`border-b ${
                    index % 2 === 0 ? "bg-gray-100" : "bg-white"
                  } hover:bg-blue-50 transition duration-300`}
                >
                  <td className="py-3 px-4">{index + 1}</td>
                  <td className="py-3 px-4">{category.category_name}</td>
                  <td className="py-3 px-4">{category.description}</td>
                  <td className="py-3 px-4 text-center">
                    <FoodCategoriesEdit
                      category={category}
                      onEdit={fetchCategories}
                    />

                    <button
                      onClick={() => handleDelete(category.id)}
                      className="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded-full shadow-md hover:shadow-lg transition duration-300 transform hover:scale-105"
                    >
                      ลบ
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default FoodCategories;
