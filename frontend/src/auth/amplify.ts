import { Amplify } from "aws-amplify"

Amplify.configure({
  Auth: {
    Cognito: {
      userPoolId: import.meta.env.VITE_COGNITO_USER_POOL_ID as string,
      userPoolClientId: import.meta.env
        .VITE_COGNITO_USER_POOL_CLIENT_ID as string,
      identityPoolId: import.meta.env.VITE_COGNITO_IDENTITY_POOL_ID as string,
      loginWith: {
        email: true,
      },
      signUpVerificationMethod: "code",
      userAttributes: {
        email: {
          required: true,
        },
      },
    
      allowGuestAccess: true,
      passwordFormat: {
        minLength: 8,
      },
    },
  },
})
