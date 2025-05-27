import "./index.scss";

import App from "./App.jsx";
import { Provider as GraphQLProvider } from "urql";
import { StrictMode } from "react";
import { apiClient } from "./api";
import { createRoot } from "react-dom/client";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <GraphQLProvider value={apiClient}>
      <App />
    </GraphQLProvider>
  </StrictMode>
);
