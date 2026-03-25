import "./styles/index.css";
import App from "./app/App.tsx";
import { createRoot } from "react-dom/client";
import { initKakao } from "./shared/lib/kakao";

initKakao();

createRoot(document.getElementById("root")!).render(<App />);