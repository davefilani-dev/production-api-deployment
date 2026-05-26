from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def root():
   return {
     "message": "API is running"
   }

@router.get("/health")
async def health():
   return {
      "message": "healthy"
   }

@router.get("/me")
async def me():
    return {
      "name": "OLUWASEUN OLANREWAJU FILANI",
      "email": "ooluwaseunfilani@gmail.com",
      "github": "https://github.com/davefilani-dev"

    }
