import ReactMarkdown from "react-markdown";
import { Card, CardContent } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";

interface ResponsePromptComponentProps {
  responsePrompt: string;
}

const ResponsePromptComponent = ({
  responsePrompt,
}: ResponsePromptComponentProps) => {
  return (
    <Card className="w-[80%] ml-3 rounded-md ">
      <CardContent>
        <ScrollArea className="h-60 overflow-y-auto">
          {responsePrompt.length > 0 && (
            <ReactMarkdown>{responsePrompt}</ReactMarkdown>
          )}
        </ScrollArea>
      </CardContent>
    </Card>
  );
};

export default ResponsePromptComponent;
