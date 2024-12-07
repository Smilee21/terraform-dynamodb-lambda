// FormComponent.tsx
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-provider-cognito-identity";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { fetchAuthSession } from "aws-amplify/auth";

const formSchema = z.object({
  client: z
    .string()
    .min(2, { message: "client must be at least 2 characters." }),
  country: z
    .string()
    .min(2, { message: "country must be at least 2 characters." }),
  serviceDescription: z
    .string()
    .min(2, { message: "serviceDescription must be at least 2 characters." }),
  awsServiceToImplement: z.string().min(2, {
    message: "awsServiceToImplement must be at least 2 characters.",
  }),
  currentMethod: z
    .string()
    .min(2, { message: "currentMethod must be at least 2 characters." }),
  newSystemMethod: z
    .string()
    .min(2, { message: "newSystemMethod must be at least 2 characters." }),
  successCriteria: z
    .string()
    .min(2, { message: "successCriteria must be at least 2 characters." }),
});

interface FormComponentProps {
  setResponsePrompt: React.Dispatch<React.SetStateAction<string>>;
}

const FormComponent = ({ setResponsePrompt }: FormComponentProps) => {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      client: "",
      country: "",
      serviceDescription: "",
      awsServiceToImplement: "",
      currentMethod: "",
      newSystemMethod: "",
      successCriteria: "",
    },
  });

  async function onSubmit(data: z.infer<typeof formSchema>) {
    try {
      const session = await fetchAuthSession();
      const idToken = session?.tokens?.idToken;

      if (idToken) {
        const lambdaClient = new LambdaClient({
          region: "us-east-1",
          credentials: fromCognitoIdentityPool({
            clientConfig: { region: "us-east-1" },
            identityPoolId: import.meta.env
              .VITE_COGNITO_IDENTITY_POOL_ID as string,
            logins: {
              [`cognito-idp.${import.meta.env.VITE_AWS_REGION}.amazonaws.com/${
                import.meta.env.VITE_COGNITO_USER_POOL_ID
              }`]: idToken.toString(),
            },
          }),
        });

        const params = {
          FunctionName: "myLambdaFunction",
          Payload: JSON.stringify({
            prompt: "PROMPT#123",
            parameters: {
              client: data.client,
              country: data.country,
              serviceDescription: data.serviceDescription,
              awsServiceToImplement: data.awsServiceToImplement,
              currentMethod: data.currentMethod,
              newSystemMethod: data.newSystemMethod,
              successCriteria: data.successCriteria,
            },
          }),
        };

        const command = new InvokeCommand(params);
        const response = await lambdaClient.send(command);

        const responsePayload = JSON.parse(
          new TextDecoder().decode(response.Payload)
        );

        setResponsePrompt(responsePayload.body);
      }
    } catch (error) {
      console.error("Error de autenticación o invocación de Lambda:", error);
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="relative ">
        <FormField
          control={form.control}
          name="client"
          render={({ field }) => (
            <FormItem>
              <FormLabel>¿Quién es el cliente?</FormLabel>
              <FormControl>
                <Input placeholder="Max Martin" {...field} />
              </FormControl>
              <FormDescription>Aqui va el nombre del cliente</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="country"
          render={({ field }) => (
            <FormItem>
              <FormLabel>¿Qué país es?</FormLabel>
              <FormControl>
                <Input placeholder="Colombia" {...field} />
              </FormControl>
              <FormDescription>
                Coloca el pais de donde es el cliente
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="serviceDescription"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Descripción del servicio</FormLabel>
              <FormControl>
                <Input placeholder="Un servicio asombroso" {...field} />
              </FormControl>
              <FormDescription>
                Describe el servicio que quieres
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="awsServiceToImplement"
          render={({ field }) => (
            <FormItem>
              <FormLabel>AWS Service a implementar</FormLabel>
              <FormControl>
                <Input placeholder="DynamoDB" {...field} />
              </FormControl>
              <FormDescription>
                Nombra los servios de AWS a Implementar
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="currentMethod"
          render={({ field }) => (
            <FormItem>
              <FormLabel>¿Cómo lo hace el cliente actualmente?</FormLabel>
              <FormControl>
                <Input placeholder="Excel" {...field} />
              </FormControl>
              <FormDescription>
                Describe como el cliente realiza sus tareas o requerimientos
                actualmente
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="newSystemMethod"
          render={({ field }) => (
            <FormItem>
              <FormLabel> ¿Cómo lo haría con el nuevo sistema?</FormLabel>
              <FormControl>
                <Input placeholder="sk's" {...field} />
              </FormControl>
              <FormDescription>
                Describe como con el nuevo sistema se haria la tarea o
                resolveria el problema
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="successCriteria"
          render={({ field }) => (
            <FormItem>
              <FormLabel> ¿Cuál es el criterio de éxito?</FormLabel>
              <FormControl>
                <Input placeholder="Tener mejor rendimiendo" {...field} />
              </FormControl>
              <FormDescription>
                Describe que es lo que haria que se considere exitosa la
                implementacion
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit">Enviar</Button>
      </form>
    </Form>
  );
};

export default FormComponent;
