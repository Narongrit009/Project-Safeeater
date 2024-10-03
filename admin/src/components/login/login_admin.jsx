import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import logo from "../../../public/image/logo3.png";
import bgfood from "../../../public/image/bgfood.jpeg";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faEye, faEyeSlash } from "@fortawesome/free-solid-svg-icons";

const LoginAdmin = ({ setIsAuthenticated }) => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const response = await axios.post(
        `${import.meta.env.VITE_API_URL_CHECK_LOGIN_ADMIN}`,
        {
          email,
          password,
        }
      );

      if (response.data.status === "success") {
        localStorage.setItem("adminEmail", response.data.email);

        Swal.fire({
          title: "เข้าสู่ระบบสำเร็จ!",
          text: "คุณกำลังถูกนำไปยังหน้าแดชบอร์ด",
          icon: "success",
          confirmButtonText: "ตกลง",
          timer: 1500,
          showConfirmButton: false,
        }).then(() => {
          setIsAuthenticated(true);
          navigate("/dashboard");
        });
      } else {
        Swal.fire({
          title: "เข้าสู่ระบบไม่สำเร็จ!",
          text: "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
          icon: "error",
          confirmButtonText: "ตกลง",
        });
      }
    } catch (err) {
      console.error(err);
      Swal.fire({
        title: "เกิดข้อผิดพลาด!",
        text: "มีบางอย่างผิดพลาด โปรดลองใหม่อีกครั้ง",
        icon: "error",
        confirmButtonText: "ตกลง",
      });
    }
  };

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  return (
    <div
      className="min-h-screen flex items-center justify-center bg-cover bg-center"
      style={{ backgroundImage: `url(${bgfood})` }}
    >
      <div className="w-full max-w-md bg-white p-10 rounded-xl shadow-2xl transition duration-500 hover:shadow-2xl transform hover:scale-105">
        {/* โลโก้ */}
        <div className="flex justify-center mb-6">
          <img src={logo} alt="Logo" className="w-36 h-36 object-cover" />
        </div>

        <h2 className="text-4xl font-bold text-center mb-6 text-transparent bg-clip-text bg-gradient-to-r from-blue-500 to-purple-600">
          เข้าสู่ระบบผู้ดูแล
        </h2>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="relative">
            <label
              className="block text-gray-700 font-semibold mb-2"
              htmlFor="email"
            >
              อีเมล
            </label>
            <input
              type="email"
              id="email"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="relative">
            <label
              className="block text-gray-700 font-semibold mb-2"
              htmlFor="password"
            >
              รหัสผ่าน
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                id="password"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-300 pr-12"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              {/* ปุ่มแสดง/ซ่อนรหัสผ่าน */}
              <span
                onClick={togglePasswordVisibility}
                className="absolute inset-y-0 right-3 flex items-center cursor-pointer"
              >
                <FontAwesomeIcon
                  icon={showPassword ? faEyeSlash : faEye}
                  className="text-gray-500"
                />
              </span>
            </div>
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-bold rounded-lg shadow-lg hover:from-blue-600 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-300 transform hover:scale-105"
          >
            เข้าสู่ระบบ
          </button>
        </form>
      </div>
    </div>
  );
};

export default LoginAdmin;
