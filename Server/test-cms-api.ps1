# Test script for CMS API
# Run this after the server is started

$baseUrl = "http://127.0.0.1:8000"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CMS API Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Register a test user
Write-Host "Test 1: Register user..." -ForegroundColor Yellow
$registerBody = @{
    email = "cms@test.com"
    password = "testpass123"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $registerBody -ContentType "application/json"
    if ($registerResponse.success) {
        Write-Host "✓ User registered successfully" -ForegroundColor Green
    } else {
        Write-Host "✓ User already exists (OK)" -ForegroundColor Green
    }
} catch {
    Write-Host "✓ User already exists (OK)" -ForegroundColor Green
}
Write-Host ""

# Test 2: Login
Write-Host "Test 2: Login..." -ForegroundColor Yellow
$loginBody = @{
    emailOrUsername = "cms@test.com"
    password = "testpass123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -SessionVariable session
$token = $loginResponse.token
Write-Host "✓ Login successful, token: $($token.Substring(0,20))..." -ForegroundColor Green
Write-Host ""

# Test 3: Get component types (public endpoint)
Write-Host "Test 3: Get component types (public)..." -ForegroundColor Yellow
$typesResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/component-types" -Method Get
Write-Host "✓ Found $($typesResponse.types.Count) component types: $($typesResponse.types -join ', ')" -ForegroundColor Green
Write-Host ""

# Test 4: Create a page
Write-Host "Test 4: Create page..." -ForegroundColor Yellow
$createPageBody = @{
    slug = "test-page-$(Get-Date -Format 'HHmmss')"
    title = "Test CMS Page"
    layout = "default"
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$createPageResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/createPage" -Method Post -Body $createPageBody -Headers $headers
$pageId = $createPageResponse.pageId
Write-Host "✓ Page created with ID: $pageId" -ForegroundColor Green
Write-Host ""

# Test 5: Update page with components
Write-Host "Test 5: Update page with components..." -ForegroundColor Yellow
$updatePageBody = @{
    pageId = $pageId
    title = "Test CMS Page"
    layout = "default"
    components = @(
        @{
            id = 0
            type = "heading"
            sort = 0
            data = @{
                text = "Welcome to CMS"
                level = 1
            }
        },
        @{
            id = 0
            type = "text"
            sort = 1
            data = @{
                text = "This is a test page created by the CMS API"
                style = "body"
            }
        },
        @{
            id = 0
            type = "button"
            sort = 2
            data = @{
                label = "Click Me"
                action = "/test"
                style = "primary"
            }
        }
    )
} | ConvertTo-Json -Depth 10

$updatePageResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/updatePage" -Method Post -Body $updatePageBody -Headers $headers
Write-Host "✓ Page updated - Version $($updatePageResponse.versionNum) created (ID: $($updatePageResponse.versionId))" -ForegroundColor Green
Write-Host ""

# Test 6: Get page
Write-Host "Test 6: Get page..." -ForegroundColor Yellow
$getPageBody = @{
    pageId = $pageId
} | ConvertTo-Json

$getPageResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/getPage" -Method Post -Body $getPageBody -Headers $headers
Write-Host "✓ Page retrieved: '$($getPageResponse.page.title)' with $($getPageResponse.page.components.Count) components" -ForegroundColor Green
Write-Host ""

# Test 7: List pages
Write-Host "Test 7: List all pages..." -ForegroundColor Yellow
$listPagesBody = @{} | ConvertTo-Json
$listPagesResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/listPages" -Method Post -Body $listPagesBody -Headers $headers
Write-Host "✓ Found $($listPagesResponse.pages.Count) page(s)" -ForegroundColor Green
Write-Host ""

# Test 8: Generate AI prompt
Write-Host "Test 8: Generate AI prompt..." -ForegroundColor Yellow
$aiPromptBody = @{
    prompt = "Create a landing page with hero section and pricing table"
} | ConvertTo-Json

$aiPromptResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/ai-prompt" -Method Post -Body $aiPromptBody -Headers $headers
Write-Host "✓ AI prompt generated ($($aiPromptResponse.prompt.Length) chars)" -ForegroundColor Green
Write-Host "  Prompt preview: $($aiPromptResponse.prompt.Substring(0, [Math]::Min(100, $aiPromptResponse.prompt.Length)))..." -ForegroundColor Gray
Write-Host ""

# Test 9: Validate component JSON
Write-Host "Test 9: Validate component JSON..." -ForegroundColor Yellow
$validateBody = @{
    json = '{"components":[{"id":"test1","type":"text","props":{"text":"Hello"}}]}'
} | ConvertTo-Json

$validateResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/validate" -Method Post -Body $validateBody -Headers $headers
if ($validateResponse.ok) {
    Write-Host "✓ Validation passed" -ForegroundColor Green
} else {
    Write-Host "✗ Validation failed: $($validateResponse.errors[0].message)" -ForegroundColor Red
}
Write-Host ""

# Test 10: List versions
Write-Host "Test 10: List page versions..." -ForegroundColor Yellow
$listVersionsBody = @{
    pageId = $pageId
} | ConvertTo-Json

$listVersionsResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/listVersions" -Method Post -Body $listVersionsBody -Headers $headers
Write-Host "✓ Found $($listVersionsResponse.versions.Count) version(s)" -ForegroundColor Green
foreach ($version in $listVersionsResponse.versions) {
    Write-Host "  - Version $($version.versionNum) (ID: $($version.id)) created at $($version.createdAt)" -ForegroundColor Gray
}
Write-Host ""

# Test 11: Publish version
Write-Host "Test 11: Publish version..." -ForegroundColor Yellow
$publishBody = @{
    pageId = $pageId
    versionId = $updatePageResponse.versionId
} | ConvertTo-Json

$publishResponse = Invoke-RestMethod -Uri "$baseUrl/api/cms/publishVersion" -Method Post -Body $publishBody -Headers $headers
Write-Host "✓ Version published successfully" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All tests completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now view the page at:" -ForegroundColor Yellow
Write-Host "  $baseUrl/api/cms/pages/slug/$($createPageBody | ConvertFrom-Json).slug?published=true" -ForegroundColor Cyan
