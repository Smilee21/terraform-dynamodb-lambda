type ErrorMessageProps = {
  message?: string
}

const ErrorMessage: React.FC<ErrorMessageProps> = ({ message }) => {
  if (!message) return null
  return <p style={{ color: "red" }}>{message}</p>
}

export default ErrorMessage
