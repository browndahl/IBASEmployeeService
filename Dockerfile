FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 5296

ENV ASPNETCORE_URLS=http://+:5296

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["IBASEmployeeService.csproj", "./"]
RUN dotnet restore "IBASEmployeeService.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "IBASEmployeeService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "IBASEmployeeService.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "IBASEmployeeService.dll"]
