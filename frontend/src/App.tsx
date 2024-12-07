import { useState } from "react";
import { Authenticator } from "@aws-amplify/ui-react";
import FormComponent from "@/components/PromptForm";
import ResponsePromptComponent from "@/components/ResponsePrompt";
import { NavigationMenuDemo } from "./components/navbar.tsx";
import { ThemeProvider } from "@/components/theme-provider";
import "./auth/amplify.ts";
import "@aws-amplify/ui-react/styles.css";
import { BrowserRouter as Router } from "react-router-dom";

const App = () => {
  const [responsePrompt, setResponsePrompt] = useState("");

  return (
    <Authenticator className="pt-24">
      <Router>
        <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
          <NavigationMenuDemo />
          <div className="flex w-full pt-4 pb-4 px-10 ">
            <FormComponent setResponsePrompt={setResponsePrompt} />
            <ResponsePromptComponent responsePrompt={responsePrompt} />
          </div>
        </ThemeProvider>
      </Router>
    </Authenticator>
  );
};

export default App;
