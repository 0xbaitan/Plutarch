import {BrowserRouter, Route, Routes} from 'react-router-dom'
import RegisterPage from './features/authentication/Register'


export enum RoutePaths {
    REGISTER_PATH = '/register',
}   

export default function Router() {

    return (
        <BrowserRouter >
            <Routes>
                <Route path={RoutePaths.REGISTER_PATH} element={<RegisterPage />} />
            </Routes>
        </BrowserRouter>
    )
}