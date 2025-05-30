import "./App.scss";

import Button from "./components/Button";

import { useGetAllUsersQuery } from "./api";

import Router from "./Routes";

function App() {
 
  const [{ data }] = useGetAllUsersQuery(["id", "firstName", "lastName"]);

  console.log("data", data);
  return (
    <>
    <Router />
    </>
  );
}

export default App;
