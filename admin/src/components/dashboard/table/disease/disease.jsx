import React, { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";
import Swal from "sweetalert2"; // นำเข้า SweetAlert2 สำหรับการแจ้งเตือน
import DiseaseAdd from "./disease_add.jsx";
import DiseaseEdit from "./disease_edit.jsx";

const Disease = () => {
  const [diseases, setDiseases] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState(""); // สำหรับค้นหา
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // ฟังก์ชันสลับสถานะ Sidebar
  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  // ฟังก์ชันสำหรับดึงข้อมูลโรคจาก API
  const fetchDiseases = async () => {
    try {
      const response = await axios.get(
        `${import.meta.env.VITE_API_URL_GET_DISEASES}`
      );
      setDiseases(response.data);
      setLoading(false);
    } catch (err) {
      setError(err);
      setLoading(false);
    }
  };

  // เรียกใช้ fetchDiseases เมื่อ component ถูก mount
  useEffect(() => {
    fetchDiseases();
  }, []);

  // ฟังก์ชันสำหรับค้นหา
  const handleSearch = (event) => {
    setSearchTerm(event.target.value);
  };

  // กรองข้อมูลตามคำค้นหา
  const filteredDiseases = diseases.filter((disease) =>
    disease.condition_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // ฟังก์ชันสำหรับลบโรค
  const handleDelete = (id) => {
    Swal.fire({
      title: "คุณแน่ใจหรือไม่?",
      text: "คุณจะไม่สามารถกู้คืนข้อมูลนี้ได้!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "ใช่, ลบเลย!",
      cancelButtonText: "ยกเลิก",
    }).then((result) => {
      if (result.isConfirmed) {
        // ลบข้อมูลจากฐานข้อมูล (เรียกใช้ DELETE API)
        axios
          .delete(`${import.meta.env.VITE_API_URL_GET_DISEASES}?id=${id}`) // เพิ่ม ID เป็น query parameter
          .then(() => {
            // อัปเดตข้อมูลใน state
            setDiseases(
              diseases.filter((disease) => disease.condition_id !== id)
            );
            Swal.fire("ลบแล้ว!", "ข้อมูลของคุณถูกลบเรียบร้อยแล้ว", "success");
          })
          .catch((error) => {
            Swal.fire("ข้อผิดพลาด!", "ไม่สามารถลบข้อมูลได้", "error");
          });
      }
    });
  };

  if (loading) return <div>กำลังโหลด...</div>;
  if (error) return <div>ข้อผิดพลาด: {error.message}</div>;

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-100 to-gray-200">
      {/* Sidebar */}
      <Sidebar isSidebarOpen={isSidebarOpen} />

      {/* Main Content */}
      <div className="flex-1 p-8">
        {/* Navbar */}
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-4xl font-bold text-center mb-8 text-gray-800">
          รายการโรค
        </h1>

        {/* Search Box and Add Button */}
        <div className="flex justify-between mb-6">
          <input
            type="text"
            placeholder="ค้นหาโรค"
            className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-md"
            value={searchTerm}
            onChange={handleSearch}
          />
          <DiseaseAdd onAdd={fetchDiseases} /> {/* ใช้คอมโพเนนต์ DiseaseAdd */}
        </div>

        {/* Disease Table */}
        <div className="overflow-x-auto">
          <table className="min-w-full bg-white shadow-md rounded-lg overflow-hidden">
            <thead>
              <tr className="bg-blue-500 text-white">
                <th className="py-3 px-4 text-left">#</th>
                <th className="py-3 px-4 text-left">ชื่อโรค</th>
                <th className="py-3 px-4 text-left">รายละเอียด</th>
                <th className="py-3 px-4 text-center">การกระทำ</th>
              </tr>
            </thead>
            <tbody>
              {filteredDiseases.map((disease, index) => (
                <tr
                  key={disease.condition_id}
                  className={`border-b ${
                    index % 2 === 0 ? "bg-gray-100" : "bg-white"
                  } hover:bg-blue-50 transition duration-300`}
                >
                  <td className="py-3 px-4">{index + 1}</td>
                  <td className="py-3 px-4">{disease.condition_name}</td>
                  <td className="py-3 px-4">{disease.condition_description}</td>
                  <td className="py-3 px-4 text-center">
                    <DiseaseEdit disease={disease} onEdit={fetchDiseases} />
                    <button
                      onClick={() => handleDelete(disease.condition_id)}
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

export default Disease;
