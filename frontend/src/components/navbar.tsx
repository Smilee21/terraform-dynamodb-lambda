import { Link } from "react-router-dom";
import { signOut } from "aws-amplify/auth";
import { Icons } from "@/components/icons";

export function NavigationMenuDemo() {
  const handleSignOut = async () => {
    await signOut();
  };

  return (
    <nav className="w-full flex justify-between px-10 border-[0.5px] border-[#b1b5bd61] bg-[#020817] backdrop-blur-md h-16 items-center">
      <Link to="/">PROMPT SERVICE</Link>
      <button
        onClick={handleSignOut}
        className="p-2 rounded-full hover:bg-[#1e293b] active:bg-[#0f172a] transition duration-150 ease-in-out"
      >
        <Icons.exit className="w-6 h-6 text-white" />
      </button>
    </nav>
  );
}
