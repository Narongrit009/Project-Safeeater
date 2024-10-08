import React, { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";

const FoodMenuByCategory = () => {
  const [foodItems, setFoodItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");
  const itemsPerPage = 8;
  const [isSidebarOpen, setIsSidebarOpen] = useState(true); // สถานะเปิด/ปิด Sidebar

  const navigate = useNavigate();

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  const fetchFoodItems = async () => {
    try {
      const response = await axios.get(
        `${import.meta.env.VITE_API_URL_GET_FOOD_MENU_BY_CATEGORY}`
      );
      setFoodItems(response.data);
      setLoading(false);
    } catch (err) {
      setError(err);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFoodItems(); // เรียกใช้งาน fetchFoodItems ใน useEffect
  }, []);

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1); // รีเซ็ตไปยังหน้าแรกเมื่อมีการค้นหาใหม่
  };

  const handleEdit = (menuId) => {
    navigate(`/edit-menu/${menuId}`); // เปลี่ยนเส้นทางไปยังหน้าแก้ไขเมนู
  };

  // กรองรายการอาหารตามคำค้นหา
  const filteredItems = foodItems.filter(
    (item) =>
      item.menu_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.category_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // การแบ่งหน้า
  const totalPages = Math.ceil(filteredItems.length / itemsPerPage);
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredItems.slice(indexOfFirstItem, indexOfLastItem);

  const goToPage = (page) => {
    setCurrentPage(page);
  };

  const handleDelete = async (menuId) => {
    const result = await Swal.fire({
      title: "ยืนยันการลบ",
      text: "คุณต้องการลบเมนูนี้หรือไม่?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "ลบ",
      cancelButtonText: "ยกเลิก",
    });

    if (result.isConfirmed) {
      try {
        const response = await axios.delete(
          `${import.meta.env.VITE_API_URL_DELETE_FOOD_MENU}`,
          {
            data: { menu_id: menuId },
          }
        );

        if (response.data.success) {
          Swal.fire({
            icon: "success",
            title: "ลบเมนูอาหารสำเร็จ!",
            text: "ข้อมูลได้ถูกลบแล้ว",
          }).then(() => {
            fetchFoodItems(); // เรียก fetchFoodItems เพื่อรีเฟรชรายการอาหารในหน้าปัจจุบัน
          });
        } else {
          Swal.fire("เกิดข้อผิดพลาด!", response.data.message, "error");
        }
      } catch (error) {
        Swal.fire("เกิดข้อผิดพลาด!", "ไม่สามารถลบรายการได้.", "error");
      }
    }
  };

  if (loading) return <div>กำลังโหลด...</div>;
  if (error) return <div>เกิดข้อผิดพลาด: {error.message}</div>;

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-50 to-gray-200">
      {/* Sidebar */}
      <Sidebar isSidebarOpen={isSidebarOpen} />
      {/* Main Content */}
      <div className="flex-1 p-8">
        {/* Navbar */}
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-4xl font-extrabold text-center mb-8 text-gray-800">
          เมนูอาหาร
        </h1>

        {/* ปุ่มเพิ่มเมนูอาหาร */}
        <div className="flex justify-end mb-4">
          <button
            onClick={() => navigate("/food-menu-add")}
            className="bg-gradient-to-r from-green-400 to-green-600 text-white px-6 py-2 rounded-full hover:bg-gradient-to-r hover:from-green-500 hover:to-green-700 transition duration-300 transform hover:scale-105 shadow-lg hover:shadow-2xl"
          >
            + เพิ่มเมนูอาหาร
          </button>
        </div>

        {/* กล่องค้นหา */}
        <div className="flex justify-center mb-8">
          <input
            type="text"
            placeholder="ค้นหาด้วยชื่อหรือประเภท"
            className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-lg"
            value={searchTerm}
            onChange={handleSearch}
          />
        </div>

        {/* รายการอาหาร */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {currentItems.map((item) => (
            <div
              key={item.menu_id}
              className="bg-white rounded-lg shadow-md hover:shadow-2xl transition duration-300 transform hover:scale-105 overflow-hidden relative"
            >
              {/* Card Header with Image */}
              <div className="relative h-36 bg-gradient-to-b from-white to-gray-50 flex items-center justify-center p-4">
                {item.image_url ? (
                  <img
                    src={item.image_url}
                    alt={item.menu_name}
                    className="max-h-full object-contain"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-gray-200 rounded-md">
                    <span className="text-gray-700">ไม่มีรูป</span>
                  </div>
                )}
                {/* Badge แสดงประเภท */}
                <div className="absolute top-2 right-2 bg-gradient-to-r from-yellow-500 to-orange-500 text-white px-2 py-1 rounded-lg text-xs font-semibold shadow-md">
                  {item.category_name}
                </div>
              </div>

              {/* Card Body */}
              <div className="p-4 text-center">
                <h2 className="text-lg font-semibold mb-2 text-gray-800">
                  {item.menu_name}
                </h2>

                <p className="text-xs text-gray-400">
                  <strong>สร้างเมื่อ:</strong>{" "}
                  {new Date(item.created_at).toLocaleDateString()}
                </p>
                <div className="p-4 text-center flex space-x-4 justify-center">
                  {/* ปุ่มแก้ไข */}
                  <button
                    onClick={() => handleEdit(item.menu_id)}
                    className="bg-gradient-to-r from-yellow-400 to-yellow-600 text-white px-4 py-2 rounded-full hover:bg-gradient-to-r hover:from-yellow-500 hover:to-yellow-700 transition duration-300 transform hover:scale-105 shadow-lg hover:shadow-2xl"
                  >
                    แก้ไข
                  </button>

                  {/* ปุ่มลบ */}
                  <button
                    onClick={() => handleDelete(item.menu_id)}
                    className="bg-gradient-to-r from-red-400 to-red-600 text-white px-4 py-2 rounded-full hover:bg-gradient-to-r hover:from-red-500 hover:to-red-700 transition duration-300 transform hover:scale-105 shadow-lg hover:shadow-2xl"
                  >
                    ลบ
                  </button>

                  {/* ปุ่มดูรายละเอียด */}
                  <button
                    onClick={() => navigate(`/menu-detail/${item.menu_id}`)}
                    className="bg-gradient-to-r from-blue-400 to-blue-600 text-white px-4 py-2 rounded-full hover:bg-gradient-to-r hover:from-blue-500 hover:to-blue-700 transition duration-300 transform hover:scale-105 shadow-lg hover:shadow-2xl"
                  >
                    ดูรายละเอียด
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Pagination */}
        <div className="flex justify-center mt-8 space-x-2">
          {Array.from({ length: totalPages }, (_, index) => (
            <button
              key={index}
              onClick={() => goToPage(index + 1)}
              className={`px-4 py-2 rounded-full ${
                currentPage === index + 1
                  ? "bg-blue-500 text-white"
                  : "bg-gray-200 text-gray-700"
              } transition duration-300`}
            >
              {index + 1}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default FoodMenuByCategory;
