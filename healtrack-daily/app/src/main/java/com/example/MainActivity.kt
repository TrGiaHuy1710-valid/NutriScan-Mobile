package com.example

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.animation.*
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.data.*
import com.example.ui.AppViewModel
import com.example.ui.DashboardScreen
import com.example.ui.theme.*

class MainActivity : ComponentActivity() {
    private val viewModel: AppViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                MainContainer(viewModel)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainContainer(viewModel: AppViewModel) {
    val context = LocalContext.current
    var showScanFullScreen by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize()) {
        Scaffold(
            modifier = Modifier
                .fillMaxSize()
                .background(OffWhiteBg)
                .statusBarsPadding(),
            bottomBar = {
                CustomBottomBar(
                    currentTab = viewModel.currentTab,
                    onTabSelected = { viewModel.currentTab = it },
                    onScanClicked = { showScanFullScreen = true }
                )
            }
        ) { innerPadding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                var showDashboardScreen by remember { mutableStateOf(false) }

                if (showDashboardScreen) {
                    DashboardScreen(viewModel = viewModel, onBack = { showDashboardScreen = false })
                } else {
                    when (viewModel.currentTab) {
                        0 -> HomeScreen(viewModel, onOpenDashboard = { showDashboardScreen = true })
                        1 -> DiscoverScreen(viewModel)
                        2 -> WorkoutScreen(viewModel)
                        3 -> ProfileScreen(viewModel)
                    }
                }
            }
        }

        if (showScanFullScreen) {
            ScanFullScreen(
                viewModel = viewModel,
                onClose = { showScanFullScreen = false }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScanFullScreen(viewModel: AppViewModel, onClose: () -> Unit) {
    val context = LocalContext.current
    var activeScanSubTab by remember { mutableStateOf(0) } // 0: Dish, 1: Label, 2: Barcode
    val isAnalyzing = viewModel.isAnalyzing
    val result = viewModel.analysisResult

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0F172A)) // Night theme dark overlay
    ) {
        // --- VIEW FINDER EDGE-TO-EDGE DISPLAY ---
        when (activeScanSubTab) {
            0 -> {
                // Dish Vision Viewfinder
                Box(modifier = Modifier.fillMaxSize()) {
                    // Viewfinder Box
                    Box(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .size(240.dp)
                            .border(2.dp, EmeraldPrimary, shape = RoundedCornerShape(24.dp)),
                        contentAlignment = Alignment.Center
                    ) {
                        // Glowing brackets or targeted circle
                        Box(
                            modifier = Modifier
                                .size(210.dp)
                                .border(1.dp, Color.White.copy(alpha = 0.3f), shape = RoundedCornerShape(16.dp))
                        )
                        Icon(
                            imageVector = Icons.Default.Search,
                            contentDescription = "Target",
                            tint = EmeraldPrimary.copy(alpha = 0.8f),
                            modifier = Modifier.size(64.dp)
                        )
                    }

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .align(Alignment.BottomCenter)
                            .padding(bottom = 120.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "HEALTRACK VISION CORE: ACTIVE",
                            color = EmeraldPrimary,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(bottom = 12.dp)
                        )
                        Text(
                            text = "Mô phỏng camera nhận diện đĩa ăn. Chọn món nhanh để quét:",
                            color = Color.White.copy(alpha = 0.8f),
                            fontSize = 12.sp,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(horizontal = 24.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 20.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            val mockDishes = listOf(
                                Triple("Bún bò Huế", 420, 24) to Pair(52, 12),
                                Triple("Xôi gà chiên", 530, 18) to Pair(70, 20),
                                Triple("Gỏi cuốn tôm", 180, 12) to Pair(28, 2)
                            )
                            mockDishes.forEach { (meta, macros) ->
                                val (name, cal, pro) = meta
                                val (carb, fat) = macros
                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(Color.White.copy(alpha = 0.15f))
                                        .border(BorderStroke(1.dp, Color.White.copy(alpha = 0.15f)), RoundedCornerShape(12.dp))
                                        .clickable {
                                            viewModel.performMockScannedDish(name, cal, pro, carb, fat)
                                            Toast.makeText(context, "Đã nhận diện: $name ($cal Kcal)", Toast.LENGTH_SHORT).show()
                                            onClose()
                                        }
                                        .padding(10.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                        Text(
                                            name,
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = Color.White,
                                            textAlign = TextAlign.Center
                                        )
                                        Spacer(modifier = Modifier.height(2.dp))
                                        Text("$cal Kcal", fontSize = 11.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            1 -> {
                // Nutrition Label OCR Scanner using Gemini AI
                var textInput by remember { mutableStateOf("") }
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 24.dp)
                        .padding(top = 100.dp, bottom = 140.dp)
                        .verticalScroll(rememberScrollState()),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(100.dp)
                            .border(1.5.dp, Color.White.copy(alpha = 0.3f), shape = RoundedCornerShape(12.dp))
                            .background(Color.Black.copy(alpha = 0.4f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth(0.9f)
                                .height(1.dp)
                                .background(Color.Green.copy(alpha = 0.4f))
                        )
                        Text(
                            text = "[ SCAN AREA FOR TEXT LABEL ]",
                            color = Color.White.copy(alpha = 0.5f),
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Text(
                        text = "Nhập nhãn dinh dưỡng mặt sau bao bì thực phẩm để trợ lý Gemini phân tích tư vấn cảnh báo:",
                        color = Color.White.copy(alpha = 0.8f),
                        fontSize = 12.sp,
                        textAlign = TextAlign.Center
                    )

                    OutlinedTextField(
                        value = textInput,
                        onValueChange = { textInput = it },
                        placeholder = { Text("Đường cát, bột ngọt, chất béo bão hòa, dầu cọ...", color = Color.White.copy(alpha = 0.4f), fontSize = 12.sp) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(86.dp)
                            .testTag("ingredients_input_field"),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = Color.White.copy(alpha = 0.3f),
                            focusedLabelColor = Color.White,
                            unfocusedLabelColor = Color.White.copy(alpha = 0.7f)
                        ),
                        shape = RoundedCornerShape(12.dp)
                    )

                    // Preset tags template
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        val samples = listOf(
                            "Nước ép táo cô đặc, đường hoá học, chất điều vị, E202",
                            "Quả óc sấy, yến mạch nguyên cám, mật ong tự nhiên, muối biển"
                        )
                        samples.forEach { sampleText ->
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(Color.White.copy(alpha = 0.1f))
                                    .clickable { textInput = sampleText }
                                    .padding(6.dp)
                            ) {
                                Text(
                                    sampleText,
                                    fontSize = 11.sp,
                                    color = Color.White,
                                    maxLines = 2,
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                        }
                    }

                    Button(
                        onClick = {
                            if (textInput.isNotBlank()) {
                                viewModel.analyzeIngredientsText(textInput)
                            }
                        },
                        enabled = textInput.isNotBlank() && !isAnalyzing,
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("analyze_ingredients_button")
                    ) {
                        if (isAnalyzing) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Trợ lý Gemini đang phân tích...", fontSize = 13.sp, color = Color.White)
                        } else {
                            Icon(Icons.Filled.Info, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("Phân Tích Bằng Trí Tuệ Nhân Tạo", fontSize = 13.sp, color = Color.White)
                        }
                    }

                    if (result != null) {
                        Surface(
                            color = Color.White.copy(alpha = 0.12f),
                            shape = RoundedCornerShape(12.dp),
                            border = BorderStroke(1.dp, EmeraldPrimary.copy(alpha = 0.5f)),
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("gemini_analysis_result_card")
                        ) {
                            Column(modifier = Modifier.padding(12.dp)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        imageVector = Icons.Filled.Check,
                                        contentDescription = "Success analysis",
                                        tint = EmeraldPrimary,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        "Kết Quả Phân Tích Thực Phẩm:",
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = EmeraldPrimary
                                    )
                                }
                                Spacer(modifier = Modifier.height(6.dp))
                                Text(
                                    text = result,
                                    fontSize = 12.sp,
                                    color = Color.White,
                                    lineHeight = 18.sp
                                )
                            }
                        }
                    }
                }
            }
            2 -> {
                // Barcode vision laser simulator
                Box(modifier = Modifier.fillMaxSize()) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .fillMaxWidth(0.85f)
                            .height(130.dp)
                            .border(1.5.dp, Color.White.copy(alpha = 0.4f), RoundedCornerShape(12.dp))
                            .background(Color.Black.copy(alpha = 0.6f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth(0.9f)
                                .height(2.dp)
                                .background(Color.Red) // Glowing Red Laser line
                        )
                        Box(
                            modifier = Modifier
                                .width(200.dp)
                                .fillMaxHeight(0.7f)
                                .border(1.dp, Color.White.copy(alpha = 0.2f), RoundedCornerShape(4.dp))
                        )
                    }

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .align(Alignment.BottomCenter)
                            .padding(bottom = 120.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text(
                            text = "LASER BARCODE LOCK ON",
                            color = Color.Red,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Di chuyển mã vạch nằm giữa tia hồng ngoại. Nhấp mã mẫu:",
                            color = Color.White.copy(alpha = 0.8f),
                            fontSize = 12.sp,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(horizontal = 24.dp)
                        )

                        val barcodes = listOf(
                            "8930001" to "Sữa TH True Milk Hữu Cơ (120 Kcal)",
                            "8930002" to "Sữa chua ăn Vinamilk ít đường (110 Kcal)",
                            "8930003" to "Hạt đậu nành sấy giòn Fami (160 Kcal)"
                        )
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 24.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            barcodes.forEach { (code, title) ->
                                Button(
                                    onClick = {
                                        viewModel.performMockScannedProduct(code)
                                        Toast.makeText(context, "Đã lưu vào danh mục Bought Today!", Toast.LENGTH_SHORT).show()
                                        onClose()
                                    },
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .testTag("dummy_barcode_$code"),
                                    colors = ButtonDefaults.buttonColors(containerColor = Color.White.copy(alpha = 0.15f)),
                                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.2f)),
                                    shape = RoundedCornerShape(12.dp)
                                ) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(title, fontSize = 12.sp, color = Color.White, fontWeight = FontWeight.Medium)
                                        Text("Barcode #$code", fontSize = 11.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- GLASSMORPHISM BOTTOM CHIPS SELECTOR BAR ---
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .windowInsetsPadding(WindowInsets.navigationBars)
                .padding(20.dp)
                .clip(RoundedCornerShape(24.dp))
                .background(Color.White.copy(alpha = 0.08f)) // Glass translucent backdrop
                .border(BorderStroke(1.dp, Color.White.copy(alpha = 0.15f)), RoundedCornerShape(24.dp))
                .padding(6.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                val subTabs = listOf("Ăn uống", "Nhãn thành phần", "Thực phẩm")
                subTabs.forEachIndexed { idx, title ->
                    val isSel = activeScanSubTab == idx
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(18.dp))
                            .background(if (isSel) Color.White else Color.Transparent)
                            .clickable { activeScanSubTab = idx }
                            .padding(vertical = 12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = title,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (isSel) Color(0xFF0F172A) else Color.White.copy(alpha = 0.7f)
                        )
                    }
                }
            }
        }

        // --- TOP OVERLAY CONTROLS (Back / Title) ---
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onClose,
                modifier = Modifier
                    .size(40.dp)
                    .background(Color.Black.copy(alpha = 0.5f), CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Default.Close,
                    contentDescription = "Hủy bỏ camera",
                    tint = Color.White
                )
            }

            Text(
                text = "HEALTRACK VISION HUB",
                color = Color.White,
                fontSize = 13.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 1.sp
            )

            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(Color.Black.copy(alpha = 0.5f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .background(Color.Red, CircleShape)
                )
            }
        }
    }
}

// --- CUSTOM BOTTOM BAR ---
@Composable
fun CustomBottomBar(
    currentTab: Int,
    onTabSelected: (Int) -> Unit,
    onScanClicked: () -> Unit
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .windowInsetsPadding(WindowInsets.navigationBars),
        color = Color.White,
        tonalElevation = 2.dp,
        shadowElevation = 8.dp
    ) {
        Column {
            // Soft top border to match "border-t border-[#e2e3d8]" from HTML
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(VibrantBorderMedium)
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(72.dp)
                    .padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                // Tab 0: Home
                BottomNavItem(
                    iconSelected = Icons.Filled.Home,
                    iconUnselected = Icons.Outlined.Home,
                    label = "Trang chủ",
                    isSelected = currentTab == 0,
                    modifier = Modifier
                        .weight(1f)
                        .testTag("nav_home_tab"),
                    onClick = { onTabSelected(0) }
                )

                // Tab 1: Discover
                BottomNavItem(
                    iconSelected = Icons.Filled.Search,
                    iconUnselected = Icons.Outlined.Search,
                    label = "Món khuyên",
                    isSelected = currentTab == 1,
                    modifier = Modifier
                        .weight(1f)
                        .testTag("nav_discover_tab"),
                    onClick = { onTabSelected(1) }
                )

                // Central Scan Button
                Box(
                    modifier = Modifier
                        .size(64.dp)
                        .padding(4.dp),
                    contentAlignment = Alignment.Center
                ) {
                    IconButton(
                        onClick = onScanClicked,
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(CircleShape)
                            .background(
                                Brush.linearGradient(
                                    listOf(VibrantPrimary, VibrantSecondary)
                                )
                            )
                            .testTag("nav_scan_fab"),
                    ) {
                        Icon(
                            imageVector = Icons.Filled.Star,
                            contentDescription = "Quét thực phẩm",
                            tint = Color.White,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }

                // Tab 2: Workout
                BottomNavItem(
                    iconSelected = Icons.Filled.Favorite,
                    iconUnselected = Icons.Outlined.FavoriteBorder,
                    label = "Bài tập",
                    isSelected = currentTab == 2,
                    modifier = Modifier
                        .weight(1f)
                        .testTag("nav_workout_tab"),
                    onClick = { onTabSelected(2) }
                )

                // Tab 3: Profile
                BottomNavItem(
                    iconSelected = Icons.Filled.Person,
                    iconUnselected = Icons.Outlined.Person,
                    label = "Hồ sơ",
                    isSelected = currentTab == 3,
                    modifier = Modifier
                        .weight(1f)
                        .testTag("nav_profile_tab"),
                    onClick = { onTabSelected(3) }
                )
            }
        }
    }
}

@Composable
fun BottomNavItem(
    iconSelected: ImageVector,
    iconUnselected: ImageVector,
    label: String,
    isSelected: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxHeight()
            .clickable(onClick = onClick)
            .padding(vertical = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .height(28.dp)
                .width(52.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(if (isSelected) VibrantLightHighlight else Color.Transparent),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = if (isSelected) iconSelected else iconUnselected,
                contentDescription = label,
                tint = if (isSelected) VibrantPrimary else VibrantTextLight,
                modifier = Modifier.size(22.dp)
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            fontSize = 10.sp,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
            color = if (isSelected) VibrantPrimary else VibrantTextLight
        )
    }
}

// --- SCANNING BOTTOM SHEET CONTENT ---
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun ScanBottomSheetContent(
    viewModel: AppViewModel,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    var activeScanSubTab by remember { mutableStateOf(0) } // 0: Dish, 1: Label, 2: Barcode

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp)
            .navigationBarsPadding()
    ) {
        Text(
            text = "Máy Quét HealTrack 🤳",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = EmeraldDarkHead,
            modifier = Modifier.padding(bottom = 12.dp)
        )

        // Tab selection pills
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp)
                .background(LightGrey, RoundedCornerShape(12.dp))
                .padding(4.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            val subTabs = listOf("Ăn uống", "Nhãn thành phần", "Thực phẩm")
            subTabs.forEachIndexed { idx, title ->
                val isSel = activeScanSubTab == idx
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(if (isSel) Color.White else Color.Transparent)
                        .clickable { activeScanSubTab = idx }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = title,
                        fontSize = 12.sp,
                        fontWeight = if (isSel) FontWeight.Bold else FontWeight.Medium,
                        color = if (isSel) EmeraldPrimary else TextLight
                    )
                }
            }
        }

        when (activeScanSubTab) {
            0 -> ScanDishTabProduct(viewModel, onDismiss)
            1 -> ScanIngredientsLabelTab(viewModel)
            2 -> ScanBarcodeTab(viewModel, onDismiss)
        }

        Spacer(modifier = Modifier.height(20.dp))
    }
}

@Composable
fun ScanDishTabProduct(viewModel: AppViewModel, onDismiss: () -> Unit) {
    val context = LocalContext.current

    Column {
        Text(
            text = "Giả Lập Camera Nhận Diện Món Ăn:",
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = TextDark,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        Text(
            text = "Đưa máy ảnh trước đĩa ăn của bạn. Hệ thống sử dụng thị giác máy tính giả lập để trích xuất hàm lượng dinh dưỡng.",
            fontSize = 12.sp,
            color = TextLight,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        // Mock viewfinder box
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(Color.Black),
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize(0.8f)
                    .border(2.dp, EmeraldPrimary, shape = RoundedCornerShape(12.dp))
            )
            Icon(
                imageVector = Icons.Default.Search,
                contentDescription = "Thước ngắm ảnh",
                tint = EmeraldPrimary.copy(alpha = 0.6f),
                modifier = Modifier.size(56.dp)
            )
            Text(
                text = "HealTrack Vision Active",
                color = EmeraldPrimary,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 12.dp)
            )
        }

        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Chọn món ăn để quét:",
            fontSize = 13.sp,
            fontWeight = FontWeight.Bold,
            color = TextDark,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            val mockDishes = listOf(
                Triple("Bún bò Huế", 420, 24) to Pair(52, 12),
                Triple("Xôi gà chiên", 530, 18) to Pair(70, 20),
                Triple("Gỏi cuốn tôm", 180, 12) to Pair(28, 2)
            )

            mockDishes.forEach { (meta, macros) ->
                val (name, cal, pro) = meta
                val (carb, fat) = macros
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(12.dp))
                        .background(EmeraldLightBg)
                        .clickable {
                            viewModel.performMockScannedDish(name, cal, pro, carb, fat)
                            Toast
                                .makeText(
                                    context,
                                    "Đã nhận diện: $name ($cal Kcal)",
                                    Toast.LENGTH_SHORT
                                )
                                .show()
                            onDismiss()
                        }
                        .padding(8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            name,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = EmeraldDarkHead,
                            textAlign = TextAlign.Center
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text("$cal Kcal", fontSize = 11.sp, color = TextLight)
                    }
                }
            }
        }
    }
}

@Composable
fun ScanIngredientsLabelTab(viewModel: AppViewModel) {
    var textInput by remember { mutableStateOf("") }
    val isAnalyzing = viewModel.isAnalyzing
    val result = viewModel.analysisResult

    Column {
        Text(
            text = "Phân Tích Thành Phần Bì Sản Phẩm:",
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = TextDark,
            modifier = Modifier.padding(bottom = 6.dp)
        )
        Text(
            text = "Nhập danh sách thành phần mặt sau bao bì thực phẩm để nhận tư vấn cảnh báo dinh dưỡng nguyên bản từ trí tuệ nhân tạo Gemini.",
            fontSize = 12.sp,
            color = TextLight,
            modifier = Modifier.padding(bottom = 12.dp)
        )

        OutlinedTextField(
            value = textInput,
            onValueChange = { textInput = it },
            placeholder = { Text("Đường cát, bột ngọt, chất béo bão hòa, siro ngô fructozơ, protein đậu nành, dầu cọ...", fontSize = 13.sp) },
            modifier = Modifier
                .fillMaxWidth()
                .height(86.dp)
                .testTag("ingredients_input_field"),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = EmeraldPrimary,
                unfocusedBorderColor = LightGrey
            ),
            shape = RoundedCornerShape(12.dp)
        )

        Spacer(modifier = Modifier.height(12.dp))

        // Preset templates to choose easily
        Text(text = "Ví dụ gợi ý:", fontSize = 11.sp, color = TextLight, modifier = Modifier.padding(bottom = 4.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            val samples = listOf(
                "Nước ép táo cô đặc, đường hoá học, chất điều vị, E202",
                "Quả óc sấy, yến mạch nguyên cám, mật ong tự nhiên, muối biển"
            )
            samples.forEach { sampleText ->
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(LightGrey.copy(alpha = 0.5f))
                        .clickable { textInput = sampleText }
                        .padding(6.dp)
                ) {
                    Text(
                        sampleText,
                        fontSize = 10.sp,
                        color = TextDark,
                        maxLines = 2,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = {
                if (textInput.isNotBlank()) {
                    viewModel.analyzeIngredientsText(textInput)
                }
            },
            enabled = textInput.isNotBlank() && !isAnalyzing,
            colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier
                .fillMaxWidth()
                .testTag("analyze_ingredients_button")
        ) {
            if (isAnalyzing) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Trợ lý Gemini đang phân tích...", fontSize = 13.sp)
            } else {
                Icon(Icons.Filled.Info, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Phân Tích Bằng Trí Tuệ Nhân Tạo", fontSize = 13.sp)
            }
        }

        if (result != null) {
            Spacer(modifier = Modifier.height(12.dp))
            Surface(
                color = EmeraldLightBg,
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(1.dp, EmeraldPrimary.copy(alpha = 0.3f)),
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("gemini_analysis_result_card")
            ) {
                Column(modifier = Modifier.padding(12.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Filled.Check,
                            contentDescription = "Success analysis",
                            tint = EmeraldPrimary,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            "Kết Quả Phân Tích Thực Phẩm:",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = EmeraldDarkHead
                        )
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = result,
                        fontSize = 12.sp,
                        color = TextDark,
                        lineHeight = 18.sp
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "Lời khuyên mang tính tham khảo phi y tế.",
                        fontSize = 9.sp,
                        color = TextLight,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}

@Composable
fun ScanBarcodeTab(viewModel: AppViewModel, onDismiss: () -> Unit) {
    val context = LocalContext.current

    Column {
        Text(
            text = "Giả Lập Quét Mã Vạch Sản Phẩm:",
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = TextDark,
            modifier = Modifier.padding(bottom = 6.dp)
        )
        Text(
            text = "Nhắm mã vạch nằm giữa khung ngắm Laser hồng ngoại để xác minh sản phẩm trong cơ sở dữ liệu.",
            fontSize = 12.sp,
            color = TextLight,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        // Mock Scanning view
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(Color.Black),
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.9f)
                    .height(2.dp)
                    .background(Color.Red) // Laser line!
            )
            Box(
                modifier = Modifier
                    .width(180.dp)
                    .fillMaxHeight(0.7f)
                    .border(1.dp, Color.White.copy(alpha = 0.5f), RoundedCornerShape(4.dp))
            )
            Icon(
                imageVector = Icons.Default.Search,
                contentDescription = "Tơ laser",
                tint = Color.White.copy(alpha = 0.2f),
                modifier = Modifier.size(46.dp)
            )
        }

        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Ấn mã vạch mẫu để mô phỏng quét thực tế:",
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold,
            color = TextDark,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        Column(
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            val barcodes = listOf(
                "8930001" to "Sữa TH True Milk Hữu Cơ (120 Kcal)",
                "8930002" to "Sữa chua ăn Vinamilk ít đường (110 Kcal)",
                "8930003" to "Hạt đậu nành sấy giòn Fami (160 Kcal)"
            )

            barcodes.forEach { (code, title) ->
                OutlinedButton(
                    onClick = {
                        viewModel.performMockScannedProduct(code)
                        Toast.makeText(context, "Đã lưu vào danh mục Bought Today!", Toast.LENGTH_SHORT).show()
                        onDismiss()
                    },
                    modifier = Modifier.fillMaxWidth().testTag("dummy_barcode_$code"),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = EmeraldPrimary),
                    border = BorderStroke(1.dp, EmeraldPrimary.copy(alpha = 0.4f)),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(title, fontSize = 12.sp, color = TextDark, fontWeight = FontWeight.Medium)
                        Text("Barcode #$code", fontSize = 11.sp, color = TextLight, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

// --- HOME (DASHBOARD) SCREEN ---
@Composable
fun HomeScreen(viewModel: AppViewModel, onOpenDashboard: () -> Unit) {
    val meals by viewModel.mealsState.collectAsStateWithLifecycle()
    val workouts by viewModel.workoutsState.collectAsStateWithLifecycle()
    val profile by viewModel.profileState.collectAsStateWithLifecycle()

    val context = LocalContext.current
    val intakeCal by viewModel.totalCaloriesIntake.collectAsStateWithLifecycle()
    val burnedCal by viewModel.totalCaloriesBurned.collectAsStateWithLifecycle()

    val intakePro by viewModel.totalProteinIntake.collectAsStateWithLifecycle()
    val intakeCarb by viewModel.totalCarbsIntake.collectAsStateWithLifecycle()
    val intakeFat by viewModel.totalFatIntake.collectAsStateWithLifecycle()

    val targetCal = profile?.targetCalories ?: 2000
    val targetPro = profile?.targetProtein ?: 120
    val targetCarb = profile?.targetCarbs ?: 230
    val targetFat = profile?.targetFat ?: 67
    val isTeenager = (profile?.age ?: 20) < 18

    val netCal = intakeCal - burnedCal

    var showAddMealDialog by remember { mutableStateOf(false) }
    var selectedDayIdx by remember { mutableStateOf(1) } // Default Tuesday 13 (as in HTML UI)

    val weekdayList = listOf(
        Triple("T2", "12", "Mon"),
        Triple("T3", "13", "Tue"),
        Triple("T4", "14", "Wed"),
        Triple("T5", "15", "Thu"),
        Triple("T6", "16", "Fri")
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(VibrantBackground)
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // --- 1. TOP APP BAR HEADER (Sarah Miller inspired) ---
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Circular Sage profile accent
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(Color(0xFFDBE6D3)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.Person,
                        contentDescription = "Hồ sơ",
                        tint = VibrantSecondary,
                        modifier = Modifier.size(24.dp)
                    )
                }

                Column {
                    Text(
                        text = "Chào buổi sáng, 👋",
                        fontSize = 11.sp,
                        color = VibrantTextLight,
                        fontWeight = FontWeight.Medium
                    )
                    Text(
                        text = "Huy Nguyễn",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = VibrantTextDark
                    )
                }
            }

            // Notification button with modern soft gray border
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(Color.White)
                    .border(BorderStroke(1.dp, VibrantBorderMedium), CircleShape)
                    .clickable { 
                        Toast.makeText(context, "Hệ thống an lành: Không có thông báo mới! 🔔", Toast.LENGTH_SHORT).show()
                    },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Filled.Notifications,
                    contentDescription = "Thông báo",
                    tint = VibrantTextMedium,
                    modifier = Modifier.size(20.dp)
                )
            }
        }

        // --- 2. DAY SELECTOR STRIP (Mon 12 - Fri 16) ---
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.weight(1f)
            ) {
                weekdayList.forEachIndexed { index, (dayLabel, dateVal, english) ->
                    val isSelected = selectedDayIdx == index
                    
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(64.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(
                                if (isSelected) VibrantPrimary 
                                else if (index == 0) Color(0xFFE8F3DA) // Monday highlight
                                else Color.White
                            )
                            .border(
                                BorderStroke(
                                    1.dp, 
                                    if (isSelected) VibrantPrimary 
                                    else if (index == 0) Color(0xFFD2E0BD)
                                    else VibrantBorderMedium
                                ),
                                RoundedCornerShape(16.dp)
                            )
                            .clickable {
                                selectedDayIdx = index
                                Toast.makeText(context, "Xem nhật ký ngày thứ: $english $dateVal", Toast.LENGTH_SHORT).show()
                            }
                            .padding(vertical = 8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Text(
                                text = dayLabel,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected) Color.White.copy(alpha = 0.85f) else VibrantTextLight.copy(alpha = 0.7f)
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = dateVal,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected) Color.White else VibrantTextDark
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.width(8.dp))

            IconButton(
                onClick = {
                    Toast.makeText(context, "Mở Lịch Tháng 📅", Toast.LENGTH_SHORT).show()
                },
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .border(BorderStroke(1.dp, VibrantBorderMedium), RoundedCornerShape(12.dp))
            ) {
                Icon(
                    imageVector = Icons.Filled.DateRange,
                    contentDescription = "Chọn ngày",
                    tint = VibrantPrimary,
                    modifier = Modifier.size(20.dp)
                )
            }
        }

        // --- 2.5 DYNAMIC ANALYTICS DASHBOARD ENTRY CHIP ---
        Card(
            shape = RoundedCornerShape(18.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = BorderStroke(1.dp, VibrantBorderMedium),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp)
                .clickable { onOpenDashboard() }
                .testTag("dashboard_sub_screen_open_button")
        ) {
            Row(
                modifier = Modifier
                    .padding(horizontal = 16.dp, vertical = 12.dp)
                    .fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(32.dp)
                            .clip(CircleShape)
                            .background(VibrantLightHighlight),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Filled.Star,
                            contentDescription = null,
                            tint = VibrantPrimary,
                            modifier = Modifier.size(16.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(
                            text = "Xem Phân Tích Xu Hướng 📊",
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = VibrantTextDark
                        )
                        Text(
                            text = "Chỉ số ngày, tuần, tháng tự nhiên",
                            fontSize = 11.sp,
                            color = VibrantTextLight
                        )
                    }
                }
                Icon(
                    imageVector = Icons.Filled.Star,
                    contentDescription = null,
                    tint = VibrantVolt,
                    modifier = Modifier.size(18.dp)
                )
            }
        }

        // --- 3. DAILY PROGRESS NUTRITION CARD (Lime Sage bg, White macro pills) ---
        Card(
            shape = RoundedCornerShape(32.dp),
            colors = CardDefaults.cardColors(containerColor = VibrantLightHighlight),
            modifier = Modifier
                .fillMaxWidth()
                .testTag("energy_dashboard_gauge_card")
        ) {
            Column(modifier = Modifier.padding(20.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "Tiến Trình Dinh Dưỡng",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = VibrantTextDark
                        )
                        Text(
                            text = "Hôm nay",
                            fontSize = 11.sp,
                            color = VibrantTextLight
                        )
                    }

                    // Progress percentage token chip
                    Text(
                        text = "${((netCal.toFloat() / targetCal.toFloat()).coerceIn(0f,1f)*100).toInt()}% Mục tiêu",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = VibrantSecondary,
                        modifier = Modifier
                            .background(VibrantBorderLight, RoundedCornerShape(12.dp))
                            .padding(horizontal = 10.dp, vertical = 4.dp)
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Custom Visual Gauge details
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Circle Gauge Meter
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier.size(100.dp)
                    ) {
                        val percentage = (netCal.toFloat() / targetCal.toFloat()).coerceIn(0f, 1f)
                        CircularProgressIndicator(
                            progress = { percentage },
                            modifier = Modifier.fillMaxSize(),
                            color = VibrantPrimary,
                            strokeWidth = 10.dp,
                            trackColor = Color.White.copy(alpha = 0.4f),
                            strokeCap = StrokeCap.Round,
                        )
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                text = "$netCal",
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Black,
                                color = VibrantTextDark
                            )
                            Text(
                                text = "/ $targetCal kcal",
                                fontSize = 10.sp,
                                color = VibrantTextLight,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }

                    Spacer(modifier = Modifier.width(18.dp))

                    // Calculation row breakdown
                    Column(
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("Nạp vào 🍏", fontSize = 11.sp, color = VibrantTextDark, fontWeight = FontWeight.Medium)
                            Text("+$intakeCal kcal", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantSecondary)
                        }
                        Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(Color.White.copy(alpha = 0.5f)))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("Tiêu thụ ⚡", fontSize = 11.sp, color = VibrantTextDark, fontWeight = FontWeight.Medium)
                            Text("-$burnedCal kcal", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantAlertCoral)
                        }
                        Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(Color.White.copy(alpha = 0.5f)))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            val remaining = (targetCal - netCal).coerceAtLeast(0)
                            Text("Còn lại", fontSize = 11.sp, color = VibrantTextLight)
                            Text("$remaining kcal", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantPrimary)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))

                // High-End macro rows (White cards with 50% opacity, matching the design spec perfect)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    listOf(
                        Triple("ĐẠM", "$intakePro/${targetPro}g", (intakePro.toFloat()/targetPro.toFloat()).coerceIn(0f, 1f)),
                        Triple("CARB", "$intakeCarb/${targetCarb}g", (intakeCarb.toFloat()/targetCarb.toFloat()).coerceIn(0f, 1f)),
                        Triple("BÉO", "$intakeFat/${targetFat}g", (intakeFat.toFloat()/targetFat.toFloat()).coerceIn(0f, 1f))
                    ).forEach { (lbl, valStr, ratio) ->
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(16.dp))
                                .background(Color.White.copy(alpha = 0.5f))
                                .padding(10.dp)
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(
                                    text = lbl,
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = VibrantTextLight
                                )
                                Spacer(modifier = Modifier.height(2.dp))
                                Text(
                                    text = valStr,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = VibrantTextDark
                                )
                                Spacer(modifier = Modifier.height(6.dp))
                                // Indicator bar
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(4.dp)
                                        .clip(RoundedCornerShape(2.dp))
                                        .background(VibrantBorderLight)
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .fillMaxHeight()
                                            .fillMaxWidth(ratio)
                                            .background(VibrantPrimary)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }



        Spacer(modifier = Modifier.height(8.dp))

        Spacer(modifier = Modifier.height(12.dp))

        // Scheduled Exercise list wrapped with Beautiful 28.dp rounded Card & Light Borders
        ScheduledWorkoutModuleHome(workouts = workouts, onComplete = { id ->
            viewModel.completeWorkout(id)
        }, onDelete = { id ->
            viewModel.deleteWorkout(id)
        })

        Spacer(modifier = Modifier.height(20.dp))

        // Daily Food Log items wrapped with Beautiful 28.dp rounded Card & Light Borders
        TodayFoodLogModule(meals = meals, onDelete = { id ->
            viewModel.deleteMeal(id)
        }, onClearAll = {
            viewModel.clearAllMeals()
        })

        Spacer(modifier = Modifier.height(20.dp))
    }

    if (showAddMealDialog) {
        AddMealDialog(
            onDismiss = { showAddMealDialog = false },
            onSave = { name, type, portion, cal, pro, carb, fat ->
                viewModel.logMeal(name, type, portion, cal, pro, carb, fat)
                showAddMealDialog = false
            }
        )
    }
}

@Composable
fun CalorieSummaryCard(
    netCalories: Int,
    intake: Int,
    burned: Int,
    target: Int,
    protein: Int,
    carbs: Int,
    fat: Int,
    targetPro: Int,
    targetCarb: Int,
    targetFat: Int
) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier
            .fillMaxWidth()
            .testTag("energy_dashboard_gauge_card")
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Cân Bằng Năng Lượng Hôm Nay",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = EmeraldDarkHead
                )
                Icon(
                    imageVector = Icons.Filled.Star,
                    contentDescription = null,
                    tint = CoralAccent,
                    modifier = Modifier.size(18.dp)
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Circular Calorie indicator
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.size(110.dp)
                ) {
                    val percentage = (netCalories.toFloat() / target.toFloat()).coerceIn(0f, 1f)
                    CircularProgressIndicator(
                        progress = { percentage },
                        modifier = Modifier.fillMaxSize(),
                        color = EmeraldPrimary,
                        strokeWidth = 10.dp,
                        trackColor = LightGrey,
                        strokeCap = StrokeCap.Round,
                    )
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "$netCalories",
                            fontSize = 22.sp,
                            fontWeight = FontWeight.Black,
                            color = EmeraldDarkHead
                        )
                        Text(
                            text = "Ròng / $target kcal",
                            fontSize = 10.sp,
                            color = TextLight,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }

                Spacer(modifier = Modifier.width(20.dp))

                // Detailed Energy Calculation
                Column(
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Nạp vào 🍏", fontSize = 12.sp, color = TextDark)
                        Text("+$intake kcal", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = EmeraldPrimary)
                    }
                    HorizontalDivider(color = LightGrey)
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Tiêu hao ⚡", fontSize = 12.sp, color = TextDark)
                        Text("-$burned kcal", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = CoralAccent)
                    }
                    HorizontalDivider(color = LightGrey)
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Còn lại", fontSize = 12.sp, color = TextLight)
                        val remaining = (target - netCalories).coerceAtLeast(0)
                        Text("$remaining kcal", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Spacer(modifier = Modifier.height(18.dp))

            // Stacked Macros breakdown progress
            Text("Thành phần dinh dưỡng đa lượng (Macros):", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = TextDark)
            Spacer(modifier = Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                MacroColItem(label = "Đạm (P)", actual = protein, target = targetPro, color = EmeraldPrimary, modifier = Modifier.weight(1f))
                MacroColItem(label = "Carb (C)", actual = carbs, target = targetCarb, color = SunburstYellow, modifier = Modifier.weight(1f))
                MacroColItem(label = "Béo (F)", actual = fat, target = targetFat, color = CoralAccent, modifier = Modifier.weight(1f))
            }
        }
    }
}

@Composable
fun MacroColItem(
    label: String,
    actual: Int,
    target: Int,
    color: Color,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(label, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            Text("$actual/$target g", fontSize = 10.sp, color = TextLight)
        }
        Spacer(modifier = Modifier.height(4.dp))
        val ratio = if (target > 0) (actual.toFloat() / target.toFloat()).coerceIn(0f, 1f) else 0f
        LinearProgressIndicator(
            progress = { ratio },
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp)),
            color = color,
            trackColor = LightGrey
        )
    }
}
@Composable
fun ScheduledWorkoutModuleHome(
    workouts: List<ScheduledWorkout>,
    onComplete: (Int) -> Unit,
    onDelete: (Int) -> Unit
) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier
            .fillMaxWidth()
            .testTag("scheduled_workouts_card")
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Bài Tập Đã Lên Lịch Hôm Nay",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = EmeraldDarkHead
                )
                Text(
                    text = "${workouts.size} bài",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = EmeraldPrimary
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            if (workouts.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Filled.Favorite, contentDescription = null, tint = LightGrey, modifier = Modifier.size(36.dp))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Hôm nay chưa có bài tập nào được lên lịch.\nHãy rà soát slot giờ trống ở Tab Bài tập!",
                            fontSize = 11.sp,
                            color = TextLight,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    workouts.forEach { item ->
                        val dismissState = rememberSwipeToDismissBoxState(
                            confirmValueChange = {
                                if (it == SwipeToDismissBoxValue.EndToStart) {
                                    onDelete(item.id)
                                    true
                                } else {
                                    false
                                }
                            }
                        )
                        SwipeToDismissBox(
                            state = dismissState,
                            enableDismissFromStartToEnd = false,
                            backgroundContent = {
                                Box(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(Color.Red.copy(alpha = 0.8f))
                                        .padding(horizontal = 16.dp),
                                    contentAlignment = Alignment.CenterEnd
                                ) {
                                    Icon(Icons.Filled.Delete, contentDescription = "Xoá bài tập", tint = Color.White)
                                }
                            },
                            content = {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .background(OffWhiteBg, RoundedCornerShape(12.dp))
                                        .padding(10.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        imageVector = if (item.isCompleted) Icons.Filled.Check else Icons.Outlined.FavoriteBorder,
                                        contentDescription = null,
                                        tint = if (item.isCompleted) EmeraldPrimary else CoralAccent,
                                        modifier = Modifier.size(20.dp)
                                    )
                                    Spacer(modifier = Modifier.width(10.dp))
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(
                                            text = item.exerciseName,
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = if (item.isCompleted) TextLight else TextDark
                                        )
                                        Text(
                                            text = "⏳ ${item.duration}p | 🔥 ${item.caloriesBurned} kcal | 🕔 ${item.timeSlot}",
                                            fontSize = 11.sp,
                                            color = TextLight
                                        )
                                    }

                                    if (!item.isCompleted) {
                                        Button(
                                            onClick = { onComplete(item.id) },
                                            colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                                            shape = RoundedCornerShape(8.dp),
                                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp),
                                            modifier = Modifier
                                                .height(28.dp)
                                                .testTag("complete_workout_btn_${item.id}")
                                        ) {
                                            Text("Xong", fontSize = 11.sp, color = Color.White)
                                        }
                                    } else {
                                        Icon(
                                            Icons.Filled.Check,
                                            contentDescription = "Hoàn thành",
                                            tint = EmeraldPrimary,
                                            modifier = Modifier.padding(horizontal = 6.dp)
                                        )
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TodayFoodLogModule(
    meals: List<MealLog>,
    onDelete: (Int) -> Unit,
    onClearAll: () -> Unit
) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier
            .fillMaxWidth()
            .testTag("today_food_log_card")
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Thực Đơn Đã Ăn Hôm Nay",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = EmeraldDarkHead
                )
                if (meals.isNotEmpty()) {
                    TextButton(onClick = onClearAll) {
                        Text("Xoá tất cả", fontSize = 11.sp, color = Color.Red)
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            if (meals.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Outlined.Search, contentDescription = null, tint = LightGrey, modifier = Modifier.size(36.dp))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Chưa ghi nhận bữa ăn nào hôm nay.\nHọc đề xuất món nguyên bản ở Tab Món khuyên!",
                            fontSize = 11.sp,
                            color = TextLight,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    meals.forEach { meal ->
                        val dismissState = rememberSwipeToDismissBoxState(
                            confirmValueChange = {
                                if (it == SwipeToDismissBoxValue.EndToStart) {
                                    onDelete(meal.id)
                                    true
                                } else {
                                    false
                                }
                            }
                        )
                        SwipeToDismissBox(
                            state = dismissState,
                            enableDismissFromStartToEnd = false,
                            backgroundContent = {
                                Box(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(Color.Red.copy(alpha = 0.8f))
                                        .padding(horizontal = 16.dp),
                                    contentAlignment = Alignment.CenterEnd
                                ) {
                                    Icon(Icons.Filled.Delete, contentDescription = "Xoá món ăn", tint = Color.White)
                                }
                            },
                            content = {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .background(OffWhiteBg, RoundedCornerShape(12.dp))
                                        .padding(10.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .clip(CircleShape)
                                            .background(EmeraldLightBg)
                                            .padding(8.dp)
                                    ) {
                                        Text(
                                            meal.mealType.take(1),
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = EmeraldPrimary
                                        )
                                    }
                                    Spacer(modifier = Modifier.width(10.dp))
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(meal.foodName, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = TextDark)
                                        Text(
                                            "🍗 ${meal.portion} | 🔥 ${meal.calories} kcal | P: ${meal.protein}g C: ${meal.carbs}g F: ${meal.fat}g",
                                            fontSize = 11.sp,
                                            color = TextLight
                                        )
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

// --- ADD MEAL DIALOG ---
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddMealDialog(
    onDismiss: () -> Unit,
    onSave: (String, String, String, Int, Int, Int, Int) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var selectedType by remember { mutableStateOf("Sáng") }
    var portion by remember { mutableStateOf("1 đĩa") }
    var calories by remember { mutableStateOf("250") }
    var protein by remember { mutableStateOf("15") }
    var carbs by remember { mutableStateOf("30") }
    var fat by remember { mutableStateOf("8") }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = Color.White,
        dragHandle = { BottomSheetDefaults.DragHandle(color = EmeraldPrimary) }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .widthIn(max = 600.dp)
                .align(Alignment.CenterHorizontally)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
                .padding(top = 8.dp, bottom = 48.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Ghi Nhật Ký Bữa Ăn Mới 📝",
                fontSize = 18.sp,
                fontWeight = FontWeight.Black,
                color = EmeraldDarkHead
            )

            // Name
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Tên món ăn", color = VibrantTextMedium) },
                placeholder = { Text("Ví dụ: Bánh mì trứng ốp la", fontSize = 13.sp) },
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("add_meal_name_field"),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = EmeraldPrimary,
                    unfocusedBorderColor = VibrantBorderMedium
                ),
                shape = RoundedCornerShape(10.dp),
                singleLine = true
            )

            // Meal Category Pills
            Text("Phân loại bữa ăn:", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val categories = listOf("Sáng", "Trưa", "Tối", "Nhẹ")
                categories.forEach { type ->
                    val isSel = selectedType == type
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (isSel) EmeraldPrimary else LightGrey)
                            .clickable { selectedType = type }
                            .padding(vertical = 10.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            type,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (isSel) Color.White else TextDark
                        )
                    }
                }
            }

            // Portion
            OutlinedTextField(
                value = portion,
                onValueChange = { portion = it },
                label = { Text("Khẩu phần", color = VibrantTextMedium) },
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("add_meal_portion_field"),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = EmeraldPrimary,
                    unfocusedBorderColor = VibrantBorderMedium
                ),
                shape = RoundedCornerShape(10.dp),
                singleLine = true
            )

            // Calories
            OutlinedTextField(
                value = calories,
                onValueChange = { calories = it },
                label = { Text("Năng lượng (Kcal)", color = VibrantTextMedium) },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("add_meal_calories_field"),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = EmeraldPrimary,
                    unfocusedBorderColor = VibrantBorderMedium
                ),
                shape = RoundedCornerShape(10.dp),
                singleLine = true
            )

            // Macros
            Text("Thành phần dinh dưỡng (Macros):", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = protein,
                    onValueChange = { protein = it },
                    label = { Text("Đạm (g)", color = VibrantTextMedium) },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier
                        .weight(1f)
                        .testTag("add_meal_protein_field"),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = EmeraldPrimary,
                        unfocusedBorderColor = VibrantBorderMedium
                    ),
                    shape = RoundedCornerShape(10.dp),
                    singleLine = true
                )
                OutlinedTextField(
                    value = carbs,
                    onValueChange = { carbs = it },
                    label = { Text("Carb (g)", color = VibrantTextMedium) },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier
                        .weight(1f)
                        .testTag("add_meal_carbs_field"),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = EmeraldPrimary,
                        unfocusedBorderColor = VibrantBorderMedium
                    ),
                    shape = RoundedCornerShape(10.dp),
                    singleLine = true
                )
                OutlinedTextField(
                    value = fat,
                    onValueChange = { fat = it },
                    label = { Text("Béo (g)", color = VibrantTextMedium) },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier
                        .weight(1f)
                        .testTag("add_meal_fat_field"),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = EmeraldPrimary,
                        unfocusedBorderColor = VibrantBorderMedium
                    ),
                    shape = RoundedCornerShape(10.dp),
                    singleLine = true
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedButton(
                    onClick = onDismiss,
                    border = BorderStroke(1.dp, EmeraldPrimary),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .weight(1f)
                        .height(48.dp)
                ) {
                    Text("Huỷ", fontSize = 13.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                }

                Button(
                    onClick = {
                        if (name.isNotBlank()) {
                            onSave(
                                name,
                                selectedType,
                                portion,
                                calories.toIntOrNull() ?: 0,
                                protein.toIntOrNull() ?: 0,
                                carbs.toIntOrNull() ?: 0,
                                fat.toIntOrNull() ?: 0
                            )
                        }
                    },
                    enabled = name.isNotBlank(),
                    colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .weight(1.5f)
                        .height(48.dp)
                ) {
                    Text("Lưu Nhật Ký 💾", fontSize = 13.sp, color = Color.White, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

// --- DATA MODELS FOR MEAL RECOMMENDATIONS ---
data class MealIngredient(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val emoji: String,
    val quantity: Float, // e.g., 300g
    val unit: String,    // e.g., "g", "ml", "quả"
    val calories: Int,   // e.g., 150 kcal (per 100g or unit)
    val protein: Int     // e.g., 12g protein
)

data class RequiredIngredient(
    val name: String,
    val quantityNeeded: Float,
    val unit: String
)

data class MealRecipe(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val emoji: String,
    val description: String,
    val nutritionBrief: String, // e.g., "🔥314 Kcal | 🥩12g Protein"
    val calories: Int,
    val protein: Int,
    val requiredIngredients: List<RequiredIngredient>,
    val instructions: String = "Sơ chế nguyên liệu sạch sẽ. Đun nóng chảo với một xút dầu hoa hướng dương hoặc bơ nhạt, nấu chín các nguyên liệu trong khoảng 10-15 phút để lưu giữ dinh dưỡng tối đa."
)

// --- DISCOVER (FOODS RECOMMENDED) SCREEN ---
// TÊN TÍNH NĂNG: MÓN KHUYÊN (MEAL RECOMMENDATIONS) - SINGLE SCREEN INTERACTIVE CORE
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DiscoverScreen(viewModel: AppViewModel) {
    val context = LocalContext.current

    // 1. STATE QUẢN LÝ THỰC PHẨM HIỆN CÓ (COMPACT INVENTORY STATE - MOCK DATA)
    var availableIngredients by remember {
        mutableStateOf(
            listOf(
                MealIngredient(name = "Ức gà", emoji = "🥩", quantity = 500f, unit = "g", calories = 165, protein = 31),
                MealIngredient(name = "Bông cải", emoji = "🥦", quantity = 300f, unit = "g", calories = 34, protein = 3),
                MealIngredient(name = "Sữa tươi", emoji = "🥛", quantity = 400f, unit = "ml", calories = 62, protein = 3),
                MealIngredient(name = "Yến mạch", emoji = "🌾", quantity = 250f, unit = "g", calories = 380, protein = 13),
                MealIngredient(name = "Trứng gà", emoji = "🥚", quantity = 6f, unit = "quả", calories = 140, protein = 13),
                MealIngredient(name = "Quả bơ", emoji = "🥑", quantity = 1f, unit = "quả", calories = 160, protein = 2)
            )
        )
    }

    // 2. DANH SÁCH THỰC ĐƠN MẪU (RECIPES MOCK DATA)
    val allRecipes = remember {
        listOf(
            MealRecipe(
                name = "Yến mạch trộn sữa tươi",
                emoji = "🥣",
                description = "Bữa sáng siêu nhanh dồi dào chất xơ, hỗ trợ tiêu hóa lành mạnh.",
                nutritionBrief = "🔥314 Kcal | 🥩12g Protein",
                calories = 314,
                protein = 12,
                requiredIngredients = listOf(
                    RequiredIngredient("Yến mạch", 50f, "g"),
                    RequiredIngredient("Sữa tươi", 200f, "ml")
                ),
                instructions = "Cho yến mạch vào bát, đổ sữa tươi ngập mặt. Quay lò vi sóng 1 phút hoặc ngâm mềm trong 5 phút. Có thể thêm mật ong hoặc hạt khô nếu thích."
            ),
            MealRecipe(
                name = "Ức gà xào bông cải xanh",
                emoji = "🥦",
                description = "Món ăn kinh điển giàu protein tự nhiên của gymer, đầy đủ đạm và chất xơ.",
                nutritionBrief = "🔥364 Kcal | 🥩65g Protein",
                calories = 364,
                protein = 65,
                requiredIngredients = listOf(
                    RequiredIngredient("Ức gà", 200f, "g"),
                    RequiredIngredient("Bông cải", 100f, "g")
                ),
                instructions = "Ức gà thái hạt lựu, áp chảo với chút tỏi và hạt tiêu thơm lừng. Cho bông cải xào cùng với chút nước tương nhạt trong 5-7 phút cho tới khi chín giòn."
            ),
            MealRecipe(
                name = "Trứng chiên bông cải xanh",
                emoji = "🍳",
                description = "Sự kết hợp thơm béo thanh mát, cung cấp năng lượng đa dạng.",
                nutritionBrief = "🔥174 Kcal | 🥩14g Protein",
                calories = 174,
                protein = 14,
                requiredIngredients = listOf(
                    RequiredIngredient("Trứng gà", 2f, "quả"),
                    RequiredIngredient("Bông cải", 50f, "g")
                ),
                instructions = "Đánh tan trứng gà cùng chút hạt tiêu. Băm nhỏ bông cải rồi xào qua, sau đó đổ trứng vào chiên vàng đều hai mặt ở lửa vừa."
            ),
            MealRecipe(
                name = "Salad gà bơ cà chua",
                emoji = "🥗",
                description = "Sự béo bùi của bơ chín mọng hoà quyện với ức gà xé phay ngọt thịt.",
                nutritionBrief = "🔥485 Kcal | 🥩50g Protein",
                calories = 485,
                protein = 50,
                requiredIngredients = listOf(
                    RequiredIngredient("Ức gà", 150f, "g"),
                    RequiredIngredient("Quả bơ", 1f, "quả"),
                    RequiredIngredient("Cà chua", 1f, "quả")
                ),
                instructions = "Luộc chín ức gà rồi xé phay. Thái lát mỏng bơ và cà chua chín. Trộn tất cả cùng chút dấm balsamic, muối hồng và muỗng dầu ô liu."
            ),
            MealRecipe(
                name = "Trứng xào cà chua hành tây",
                emoji = "🍅",
                description = "Nhanh gọn, đầy màu sắc, ngọt vị tự nhiên từ hành tây và xốt cà chua ấm áp.",
                nutritionBrief = "🔥220 Kcal | 🥩15g Protein",
                calories = 220,
                protein = 15,
                requiredIngredients = listOf(
                    RequiredIngredient("Trứng gà", 2f, "quả"),
                    RequiredIngredient("Cà chua", 1f, "quả"),
                    RequiredIngredient("Hành tây", 1f, "quả")
                ),
                instructions = "Hành tây xào thơm xém cạnh, trút cà chua băm nhỏ vào đảo mềm cho ra xốt sệt. Đổ trứng gà đánh tan vào đảo đều cho tới khi chín mềm mịn màng."
            ),
            MealRecipe(
                name = "Bò lúc lắc hành tây cà chua",
                emoji = "🥩",
                description = "Món ăn giàu sắt và kẽm, thơm dậy hương tỏi cháy xém hấp dẫn dạ dày.",
                nutritionBrief = "🔥520 Kcal | 🥩42g Protein",
                calories = 520,
                protein = 42,
                requiredIngredients = listOf(
                    RequiredIngredient("Thịt bò", 200f, "g"),
                    RequiredIngredient("Hành tây", 1f, "quả"),
                    RequiredIngredient("Cà chua", 1f, "quả")
                ),
                instructions = "Thịt bò cắt khối vuông ướp tỏi tỏi dầu hào. Bật lửa lớn, áp chảo bò chín tái nhanh chóng rồi trút hành tây, cà chua cắt miếng vuông vào xốc mạnh tay."
            ),
            MealRecipe(
                name = "Cá hồi nướng măng tây bơ chanh",
                emoji = "🐟",
                description = "Nguồn cung dồi dào chất béo omega-3 và chất xơ măng tây thanh mảnh.",
                nutritionBrief = "🔥390 Kcal | 🥩32g Protein",
                calories = 390,
                protein = 32,
                requiredIngredients = listOf(
                    RequiredIngredient("Cá hồi", 150f, "g"),
                    RequiredIngredient("Măng tây", 100f, "g"),
                    RequiredIngredient("Quả chanh", 1f, "quả")
                ),
                instructions = "Cá hồi áp chảo hoặc nướng lò cùng măng tây rắc muối tiêu nhạt. Tưới lên xốt bơ chanh tươi ấm áp trước khi bầy ra đĩa."
            )
        )
    }

    // 3. STATE CÁC TÍNH NĂNG ĐI KÈM (SHOPPING LIST & TODAY CONSUMED STATE)
    var shoppingList by remember { mutableStateOf(setOf<String>()) }
    var todayMeals by remember { mutableStateOf(listOf<MealRecipe>()) }

    // DIALOG & BOTTOM SHEET STATES
    var selectedRecipeDetail by remember { mutableStateOf<MealRecipe?>(null) }
    var showAddIngredientDialog by remember { mutableStateOf(false) }

    // FORM THÊM MỚI NGUYÊN LIỆU (CRUD - CREATE STATE)
    var formName by remember { mutableStateOf("") }
    var formEmoji by remember { mutableStateOf("🥦") }
    var formQtyStr by remember { mutableStateOf("") }
    var formUnit by remember { mutableStateOf("g") }
    var formKcalStr by remember { mutableStateOf("") }
    var formProteinStr by remember { mutableStateOf("") }

    // 4. LOGIC PHÂN LOẠI MÓN ĂN TỰ ĐỘNG DỰA TRÊN TỦ LẠNH (DYNAMIC CALCULATION)
    // - Nấu được ngay: Đủ 100% nguyên liệu
    // - Thiếu 1-2 vị: Thiếu từ 1 đến 2 nguyên liệu
    // - Khám phá: Thiếu từ 3 nguyên liệu trở lên
    val (canCookList, missingFewList, exploreList) = remember(availableIngredients) {
        val canCook = mutableListOf<MealRecipe>()
        val missingFew = mutableListOf<MealRecipe>()
        val explore = mutableListOf<MealRecipe>()

        allRecipes.forEach { recipe ->
            var missingCount = 0
            recipe.requiredIngredients.forEach { req ->
                val matchingAvail = availableIngredients.find { it.name.lowercase() == req.name.lowercase() }
                if (matchingAvail == null || matchingAvail.quantity < req.quantityNeeded) {
                    missingCount++
                }
            }

            when {
                missingCount == 0 -> canCook.add(recipe)
                missingCount in 1..2 -> missingFew.add(recipe)
                else -> explore.add(recipe)
            }
        }
        Triple(canCook, missingFew, explore)
    }

    var selectedTab by remember { mutableStateOf(0) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
            .testTag("meal_rec_screen")
    ) {
        // HEADER TIÊU ĐỀ
        Row(
            modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "Món Khuyên Dinh Dưỡng 🥗",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Black,
                    color = EmeraldDarkHead
                )
                Text(
                    text = "Đề xuất thông minh theo lượng thực phẩm thực tế trong tủ lạnh.",
                    fontSize = 11.5.sp,
                    color = TextLight
                )
            }
            // Nút mở dialog thêm nhanh thực phẩm thủ công (CRUD - Create)
            Button(
                onClick = { showAddIngredientDialog = true },
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                shape = RoundedCornerShape(10.dp),
                contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp),
                modifier = Modifier.height(36.dp).testTag("open_add_ingredient_btn")
            ) {
                Icon(Icons.Filled.Add, contentDescription = null, tint = Color.White, modifier = Modifier.size(16.dp))
                Spacer(modifier = Modifier.width(4.dp))
                Text("Bơm thực phẩm", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.White)
            }
        }

        // --- GỢI Ý MÓN ĂN HÔM NAY (Relocated from HomeScreen) ---
        Column(modifier = Modifier.fillMaxWidth().padding(vertical = 12.dp)) {
            Text(
                text = "Gợi Ý Món Ăn Hôm Nay 🌟",
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = VibrantTextDark,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(170.dp)
                    .clip(RoundedCornerShape(24.dp))
                    .background(VibrantSecondary)
                    .clickable {
                        Toast.makeText(context, "Món ngon dinh dưỡng: Xem hướng dẫn chi tiết", Toast.LENGTH_SHORT).show()
                    }
            ) {
                // Background gradient
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.75f)),
                                startY = 100f
                            )
                        )
                )

                Icon(
                    imageVector = Icons.Filled.Star,
                    contentDescription = null,
                    tint = Color.White.copy(alpha = 0.05f),
                    modifier = Modifier
                        .align(Alignment.Center)
                        .size(130.dp)
                )

                var isLiked by remember { mutableStateOf(false) }
                Box(
                    modifier = Modifier
                        .padding(14.dp)
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.2f))
                        .clickable {
                            isLiked = !isLiked
                            Toast.makeText(context, if (isLiked) "Đã lưu vào danh sách yêu thích! ❤️" else "Đã bỏ yêu thích", Toast.LENGTH_SHORT).show()
                        }
                        .align(Alignment.TopEnd),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = if (isLiked) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                        contentDescription = "Yêu thích",
                        tint = if (isLiked) Color.Red else Color.White,
                        modifier = Modifier.size(18.dp)
                    )
                }

                Column(
                    modifier = Modifier
                        .align(Alignment.BottomStart)
                        .padding(16.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(
                            text = "GIÀU PROTEIN",
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Black,
                            color = VibrantTextDark,
                            modifier = Modifier
                                .background(VibrantVolt, RoundedCornerShape(8.dp))
                                .padding(horizontal = 8.dp, vertical = 2.dp)
                        )
                        Text(
                            text = "• 25 phút",
                            fontSize = 11.sp,
                            color = Color.White.copy(alpha = 0.8f)
                        )
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Cá Hồi Áp Chảo Sốt Bơ Tỏi",
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = "Nướng ăn kèm măng tây dại và thảo mộc Địa Trung Hải tươi.",
                        fontSize = 11.sp,
                        color = Color.White.copy(alpha = 0.7f),
                        maxLines = 1
                    )
                }

                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(16.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White.copy(alpha = 0.9f))
                        .clickable {
                            viewModel.logMeal(
                                "Cá hồi áp chảo sốt bơ tỏi 🍋",
                                "Trưa",
                                "1 đĩa",
                                420,
                                30,
                                10,
                                12
                            )
                            Toast.makeText(context, "Đã ghi nhận Cá hồi sốt bơ tỏi (420 Kcal) vào nhật ký ăn uống! 🐟", Toast.LENGTH_SHORT).show()
                        }
                        .padding(horizontal = 10.dp, vertical = 6.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.Add, contentDescription = null, tint = VibrantPrimary, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(3.dp))
                        Text("Ăn ngay", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = VibrantPrimary)
                    }
                }
            }
        }

        // ==========================================
        // KHU VỰC 1: BẢNG THỰC PHẨM HIỆN CÓ (Compact Inventory Panel) Let's make it scroll horizontally!
        // ==========================================
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = BorderStroke(1.dp, VibrantBorderMedium),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp)
                .testTag("compact_inventory_panel")
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("🧊", fontSize = 16.sp)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "Tủ lạnh hiện có của bạn:",
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = VibrantTextDark
                        )
                    }
                    Text(
                        text = "${availableIngredients.count { it.quantity > 0f }} loại sẵn sàng",
                        fontSize = 11.sp,
                        color = VibrantPrimary,
                        fontWeight = FontWeight.Bold
                    )
                }

                if (availableIngredients.isEmpty()) {
                    Box(
                        modifier = Modifier.fillMaxWidth().height(100.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("Tủ lạnh trống trơn! Hãy nhấn nút Thêm thực phẩm 👆", fontSize = 11.5.sp, color = TextLight)
                    }
                } else {
                    // CÁC THẺ CARD CỰC KỲ NHỎ GỌN (Compact Card) CUỘN NGANG
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState()),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        availableIngredients.forEach { item ->
                            val isOutOfStock = item.quantity <= 0f
                            Box(
                                modifier = Modifier
                                    .width(135.dp)
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(if (isOutOfStock) Color(0xFFFBFBFB) else VibrantBackground)
                                    .border(
                                        BorderStroke(
                                            1.dp,
                                            if (isOutOfStock) VibrantBorderMedium else VibrantBorderLight
                                        ),
                                        RoundedCornerShape(12.dp)
                                    )
                                    .padding(8.dp)
                                    .testTag("ingredient_card_${item.name}")
                            ) {
                                Column {
                                    // Row đầu tiên: Emoji & Nút Xóa nhỏ gọn
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(text = item.emoji, fontSize = 20.sp)
                                        IconButton(
                                            onClick = {
                                                availableIngredients = availableIngredients.filterNot { it.id == item.id }
                                                Toast.makeText(context, "Đã bỏ ${item.name} khỏi tủ lạnh! 🗑️", Toast.LENGTH_SHORT).show()
                                            },
                                            modifier = Modifier.size(20.dp)
                                        ) {
                                            Icon(
                                                imageVector = Icons.Filled.Close,
                                                contentDescription = "Xoá",
                                                tint = VibrantAlertCoral.copy(alpha = 0.7f),
                                                modifier = Modifier.size(12.dp)
                                            )
                                        }
                                    }

                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = item.name,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = if (isOutOfStock) TextLight else VibrantTextDark,
                                        maxLines = 1
                                    )
                                    
                                    // Thông số dinh dưỡng rút gọn
                                    Text(
                                        text = "🔥${item.calories} | 🥩${item.protein}g đạm",
                                        fontSize = 9.5.sp,
                                        color = VibrantTextLight
                                    )

                                    Spacer(modifier = Modifier.height(6.dp))

                                    // QUẢN LÝ SỐ LƯỢNG (Nút +/- siêu nhỏ)
                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .background(Color.White, RoundedCornerShape(8.dp))
                                            .border(BorderStroke(0.5.dp, VibrantBorderMedium), RoundedCornerShape(8.dp))
                                            .padding(vertical = 2.dp, horizontal = 4.dp),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        // Nút GIẢM (-)
                                        Box(
                                            modifier = Modifier
                                                .size(20.dp)
                                                .clip(RoundedCornerShape(4.dp))
                                                .background(VibrantLightHighlight.copy(alpha = 0.5f))
                                                .clickable {
                                                    availableIngredients = availableIngredients.map {
                                                        if (it.id == item.id) {
                                                            val step = if (item.unit == "quả") 1f else 50f
                                                            it.copy(quantity = (it.quantity - step).coerceAtLeast(0f))
                                                        } else it
                                                    }
                                                },
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text("-", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = VibrantPrimary)
                                        }

                                        // Hiển thị số lượng
                                        Text(
                                            text = if (item.unit == "quả") "${item.quantity.toInt()}" else "${item.quantity.toInt()}${item.unit}",
                                            fontSize = 10.5.sp,
                                            fontWeight = FontWeight.Black,
                                            color = VibrantTextDark
                                        )

                                        // Nút TĂNG (+)
                                        Box(
                                            modifier = Modifier
                                                .size(20.dp)
                                                .clip(RoundedCornerShape(4.dp))
                                                .background(VibrantLightHighlight.copy(alpha = 0.5f))
                                                .clickable {
                                                    availableIngredients = availableIngredients.map {
                                                        if (it.id == item.id) {
                                                            val step = if (item.unit == "quả") 1f else 50f
                                                            it.copy(quantity = it.quantity + step)
                                                        } else it
                                                    }
                                                },
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text("+", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = VibrantPrimary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // KHU VỰC 2: ĐỀ XUẤT MÓN ĂN (Recommendation Board)
        // ==========================================
        Text(
            text = "Gợi Ý Món Khuyên Ăn Tự Động: 🍽️",
            fontSize = 13.5.sp,
            fontWeight = FontWeight.Bold,
            color = VibrantTextDark,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        // BẢNG TAB BAR gồm 3 mục: "Nấu được ngay", "Thiếu 1-2 vị", "Khám phá"
        val tabTitles = listOf(
            "Nấu được ngay ✅ (${canCookList.size})",
            "Thiếu 1-2 vị ⚠️ (${missingFewList.size})",
            "Khám phá 🔭 (${exploreList.size})"
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.White, RoundedCornerShape(12.dp))
                .border(BorderStroke(1.dp, VibrantBorderMedium), RoundedCornerShape(12.dp))
                .padding(4.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            tabTitles.forEachIndexed { index, title ->
                val isSelected = selectedTab == index
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(if (isSelected) VibrantPrimary else Color.Transparent)
                        .clickable { selectedTab = index }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = title,
                        fontSize = 11.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = if (isSelected) Color.White else VibrantTextMedium,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // DANH SÁCH MÓN ĂN THEO CHỌN LỰA CỦA TAB ĐANG CHỌN
        val activeRecipeList = when (selectedTab) {
            0 -> canCookList
            1 -> missingFewList
            else -> exploreList
        }

        if (activeRecipeList.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White, RoundedCornerShape(16.dp))
                    .border(BorderStroke(1.dp, VibrantBorderMedium), RoundedCornerShape(16.dp))
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("🥘🌧️", fontSize = 32.sp)
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "Không có món ăn tương thích!",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = VibrantTextDark
                    )
                    Text(
                        text = "Vui lòng tăng bớt số lượng thực phẩm ở tủ lạnh để AI tự động gợi ý nhé.",
                        fontSize = 11.sp,
                        color = TextLight,
                        textAlign = TextAlign.Center
                    )
                }
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                activeRecipeList.forEach { recipe ->
                    val missingIngredientsForThis = recipe.requiredIngredients.filter { req ->
                        val matchingAvail = availableIngredients.find { it.name.lowercase() == req.name.lowercase() }
                        matchingAvail == null || matchingAvail.quantity < req.quantityNeeded
                    }

                    Card(
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, VibrantBorderMedium),
                        shape = RoundedCornerShape(16.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedRecipeDetail = recipe }
                            .testTag("recipe_item_${recipe.name}")
                    ) {
                        Row(
                            modifier = Modifier.padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            // Hình EMOJI đại diện với khung tròn màu nhã nhặn
                            Box(
                                modifier = Modifier
                                    .size(48.dp)
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(VibrantLightHighlight.copy(alpha = 0.4f)),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(text = recipe.emoji, fontSize = 24.sp)
                            }

                            Spacer(modifier = Modifier.width(12.dp))

                            Column(modifier = Modifier.weight(1f)) {
                                Text(
                                    text = recipe.name,
                                    fontSize = 13.5.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = VibrantTextDark
                                )
                                Text(
                                    text = recipe.nutritionBrief,
                                    fontSize = 10.5.sp,
                                    color = CoralAccent,
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text(
                                    text = recipe.description,
                                    fontSize = 11.sp,
                                    color = TextLight,
                                    maxLines = 1
                                )

                                // HIỂN THỊ CẢNH BÁO NGUYÊN LIỆU THIẾU MÀU CAM "Thiếu: Cà chua, hành"
                                if (missingIngredientsForThis.isNotEmpty()) {
                                    val missingNames = missingIngredientsForThis.map { it.name }.joinToString(", ")
                                    Box(
                                        modifier = Modifier
                                            .padding(top = 4.dp)
                                            .background(VibrantSunburst.copy(alpha = 0.12f), RoundedCornerShape(4.dp))
                                            .padding(horizontal = 6.dp, vertical = 2.dp)
                                    ) {
                                        Text(
                                            text = "⚠️ Thiếu: $missingNames",
                                            fontSize = 9.5.sp,
                                            color = Color(0xFFD35400),
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                } else {
                                    Box(
                                        modifier = Modifier
                                            .padding(top = 4.dp)
                                            .background(VibrantPrimary.copy(alpha = 0.12f), RoundedCornerShape(4.dp))
                                            .padding(horizontal = 6.dp, vertical = 2.dp)
                                    ) {
                                        Text(
                                            text = "✅ Đầy đủ nguyên liệu nấu ngay",
                                            fontSize = 9.5.sp,
                                            color = VibrantPrimary,
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                }
                            }

                            Text(
                                text = "➜",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = VibrantTextLight,
                                modifier = Modifier.padding(end = 4.dp)
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // ==========================================
        // KHU VỰC 3: GIỎ ĐI CHỢ HÔM NAY (Shopping Basket Panel)
        // ==========================================
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = BorderStroke(1.dp, VibrantBorderMedium),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp)
                .testTag("shopping_basket_panel")
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("🛒", fontSize = 16.sp)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "Giỏ Đi Chợ Hôm Nay:",
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = VibrantTextDark
                        )
                    }
                    if (shoppingList.isNotEmpty()) {
                        TextButton(
                            onClick = { shoppingList = emptySet() },
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier.height(24.dp)
                        ) {
                            Text("Xoá hết", fontSize = 11.sp, color = VibrantAlertCoral, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                if (shoppingList.isEmpty()) {
                    Box(
                        modifier = Modifier.fillMaxWidth().padding(vertical = 12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "Giỏ sạch sẽ tuyệt đối. Các nguyên liệu thiếu của món ăn sẽ đề xuất ở đây!",
                            fontSize = 11.sp,
                            color = TextLight,
                            textAlign = TextAlign.Center
                        )
                    }
                } else {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        shoppingList.forEach { ingredientName ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .background(VibrantBackground, RoundedCornerShape(8.dp))
                                    .padding(horizontal = 10.dp, vertical = 6.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "📌 $ingredientName",
                                    fontSize = 11.5.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = VibrantTextDark
                                )

                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    // Nút "Đã mua xong" -> Phục hồi nguyên liệu này vào Area 1 tủ lạnh
                                    Button(
                                        onClick = {
                                            // Lấy thông số mặc định tùy loại
                                            val defaultEmoji = when (ingredientName.lowercase()) {
                                                "cà chua" -> "🍅"
                                                "hàng tây", "hành tây" -> "🧅"
                                                "thịt bò" -> "🥩"
                                                "cá hồi" -> "🐟"
                                                "măng tây" -> "🥬"
                                                "quả chanh" -> "🍋"
                                                else -> "🥗"
                                            }
                                            val defaultQty = if (ingredientName.lowercase().contains("trứng") || ingredientName.lowercase().contains("quả") || ingredientName.lowercase() == "cà chua" || ingredientName.lowercase() == "hành tây") 3f else 200f
                                            val defaultUnit = if (ingredientName.lowercase().contains("trứng") || ingredientName.lowercase().contains("quả") || ingredientName.lowercase() == "cà chua" || ingredientName.lowercase() == "hành tây") "quả" else "g"
                                            val defaultCal = 100
                                            val defaultPro = 10

                                            val existing = availableIngredients.find { it.name.lowercase() == ingredientName.lowercase() }
                                            if (existing != null) {
                                                availableIngredients = availableIngredients.map {
                                                    if (it.id == existing.id) it.copy(quantity = it.quantity + defaultQty) else it
                                                }
                                            } else {
                                                availableIngredients = availableIngredients + MealIngredient(
                                                    name = ingredientName,
                                                    emoji = defaultEmoji,
                                                    quantity = defaultQty,
                                                    unit = defaultUnit,
                                                    calories = defaultCal,
                                                    protein = defaultPro
                                                )
                                            }

                                            shoppingList = shoppingList - ingredientName
                                            Toast.makeText(context, "Đã cất '$ingredientName' vào tủ lạnh! 🧊", Toast.LENGTH_SHORT).show()
                                        },
                                        colors = ButtonDefaults.buttonColors(containerColor = VibrantPrimary),
                                        shape = RoundedCornerShape(6.dp),
                                        contentPadding = PaddingValues(horizontal = 8.dp),
                                        modifier = Modifier.height(24.dp)
                                    ) {
                                        Text("Đã mua xong ✓", fontSize = 9.5.sp, color = Color.White)
                                    }

                                    // Nút Delete khỏi giỏ
                                    IconButton(
                                        onClick = { shoppingList = shoppingList - ingredientName },
                                        modifier = Modifier.size(18.dp)
                                    ) {
                                        Icon(Icons.Filled.Close, contentDescription = "Xoá", tint = Color.Red.copy(alpha = 0.5f), modifier = Modifier.size(12.dp))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // KHU VỰC 4: THỰC ĐƠN ĐÃ LÊN LỊCH HÔM NAY (Today's Scheduled Meals History)
        // ==========================================
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFF1F8E9)),
            border = BorderStroke(1.dp, VibrantPrimary.copy(alpha = 0.3f)),
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp)
                .testTag("today_scheduled_meals_card")
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                val totalCal = todayMeals.sumOf { it.calories }
                val totalPro = todayMeals.sumOf { it.protein }

                Row(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("🍳", fontSize = 16.sp)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "Lịch Trình Ăn Uống Hôm Nay:",
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = VibrantTextDark
                        )
                    }
                    if (todayMeals.isNotEmpty()) {
                        TextButton(
                            onClick = { todayMeals = emptyList() },
                            contentPadding = PaddingValues(0.dp),
                            modifier = Modifier.height(24.dp)
                        ) {
                            Text("Đặt lại", fontSize = 10.5.sp, color = VibrantAlertCoral, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                if (todayMeals.isEmpty()) {
                    Text(
                        text = "Chưa có món nào được lên lịch hôm nay. Hãy tap chọn món ăn ngon để bắt đầu rèn luyện!",
                        fontSize = 11.sp,
                        color = TextLight,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)
                    )
                } else {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        todayMeals.forEach { meal ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .background(Color.White, RoundedCornerShape(8.dp))
                                    .padding(8.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                    Text(meal.emoji, fontSize = 16.sp)
                                    Text(meal.name, fontSize = 11.5.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                                }
                                Text(
                                    text = "${meal.calories}Kcal | ${meal.protein}g P",
                                    fontSize = 10.5.sp,
                                    color = CoralAccent,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }

                        HorizontalDivider(color = VibrantPrimary.copy(alpha = 0.2f), thickness = 0.5.dp, modifier = Modifier.padding(vertical = 4.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("🔥 TỔNG TIÊU THỤ:", fontSize = 11.5.sp, fontWeight = FontWeight.Black, color = VibrantTextMedium)
                            Text(
                                text = "$totalCal Kcal | $totalPro g Protein",
                                fontSize = 12.5.sp,
                                fontWeight = FontWeight.Black,
                                color = VibrantPrimary
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))
    }

    // ==========================================
    // 1. DIALOG TRUNG GIAN THÔNG TIN CHI TIẾT MÓN ĂN & GIẢI QUYẾT NGUYÊN LIỆU (Bottom Sheet equivalent)
    // ==========================================
    if (selectedRecipeDetail != null) {
        val recipe = selectedRecipeDetail!!
        
        ModalBottomSheet(
            onDismissRequest = { selectedRecipeDetail = null },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = Color.White,
            dragHandle = { BottomSheetDefaults.DragHandle(color = EmeraldPrimary) }
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .widthIn(max = 600.dp)
                    .align(Alignment.CenterHorizontally)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 24.dp)
                    .padding(top = 12.dp, bottom = 48.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Logo & Title Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(64.dp)
                            .background(VibrantLightHighlight, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(recipe.emoji, fontSize = 32.sp)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = recipe.name,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Black,
                            color = EmeraldDarkHead
                        )
                        Text(
                            text = recipe.nutritionBrief,
                            fontSize = 13.sp,
                            color = CoralAccent,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                Text(
                    text = recipe.description,
                    fontSize = 13.sp,
                    color = TextLight,
                    lineHeight = 18.sp
                )

                Divider(color = VibrantBorderLight, thickness = 1.dp)

                // Comparison grid
                Text(
                    text = "SO SÁNH NGUYÊN LIỆU TRONG TỦ 🧊",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = VibrantTextDark
                )

                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    recipe.requiredIngredients.forEach { req ->
                        val matchingItem = availableIngredients.find { it.name.lowercase() == req.name.lowercase() }
                        val currentQuantity = matchingItem?.quantity ?: 0f
                        val isEnough = currentQuantity >= req.quantityNeeded
                        val hasAddedToShopping = shoppingList.contains(req.name)

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(VibrantBackground, RoundedCornerShape(14.dp))
                                .border(
                                    BorderStroke(
                                        1.dp,
                                        if (isEnough) EmeraldPrimary.copy(alpha = 0.3f) else VibrantAlertCoral.copy(alpha = 0.3f)
                                    ),
                                    RoundedCornerShape(14.dp)
                                )
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Text(
                                        text = req.name,
                                        fontSize = 13.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = VibrantTextDark
                                    )
                                    Box(
                                        modifier = Modifier
                                            .background(
                                                if (isEnough) Color(0xFFE2F4D5) else VibrantAlertCoral.copy(alpha = 0.1f),
                                                RoundedCornerShape(6.dp)
                                            )
                                            .padding(horizontal = 6.dp, vertical = 2.dp)
                                    ) {
                                        Text(
                                            text = if (isEnough) "Đủ" else "Thiếu",
                                            fontSize = 9.sp,
                                            color = if (isEnough) EmeraldPrimary else VibrantAlertCoral,
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                }
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = "Yêu cầu: ${req.quantityNeeded.toInt()}${req.unit} | Nhà có: ${currentQuantity.toInt()}${req.unit}",
                                    fontSize = 11.sp,
                                    color = VibrantTextMedium
                                )
                            }

                            if (!isEnough) {
                                Button(
                                    onClick = {
                                        shoppingList = shoppingList + req.name
                                        Toast.makeText(context, "Đã thêm '${req.name}' vào Giỏ đi chợ 🛒", Toast.LENGTH_SHORT).show()
                                    },
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = if (hasAddedToShopping) EmeraldPrimary else VibrantAlertCoral.copy(alpha = 0.1f)
                                    ),
                                    shape = RoundedCornerShape(10.dp),
                                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp),
                                    modifier = Modifier.height(32.dp)
                                ) {
                                    Icon(
                                        imageVector = if (hasAddedToShopping) Icons.Filled.Check else Icons.Filled.ShoppingCart,
                                        contentDescription = "Thêm đi chợ",
                                        tint = if (hasAddedToShopping) Color.White else VibrantAlertCoral,
                                        modifier = Modifier.size(12.dp)
                                    )
                                    Spacer(modifier = Modifier.width(3.dp))
                                    Text(
                                        text = if (hasAddedToShopping) "Đã thêm" else "Đi chợ",
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = if (hasAddedToShopping) Color.White else VibrantAlertCoral
                                    )
                                }
                            }
                        }
                    }
                }

                Divider(color = VibrantBorderLight, thickness = 1.dp)

                Text(
                    text = "HƯỚNG DẪN CHẾ BIẾN NẤU CHÍN 🍳",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = VibrantTextDark
                )
                Text(
                    text = recipe.instructions,
                    fontSize = 12.sp,
                    color = VibrantTextMedium,
                    lineHeight = 18.sp
                )

                Spacer(modifier = Modifier.height(12.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedButton(
                        onClick = { selectedRecipeDetail = null },
                        border = BorderStroke(1.dp, EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp)
                    ) {
                        Text("Huỷ bỏ", fontSize = 13.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                    }

                    Button(
                        onClick = {
                            recipe.requiredIngredients.forEach { req ->
                                availableIngredients = availableIngredients.map { avail ->
                                    if (avail.name.lowercase() == req.name.lowercase()) {
                                        avail.copy(quantity = (avail.quantity - req.quantityNeeded).coerceAtLeast(0f))
                                    } else avail
                                }
                            }
                            todayMeals = todayMeals + recipe
                            selectedRecipeDetail = null
                            Toast.makeText(context, "Thực đơn nấu thành công! Đã tự động trừ nguyên liệu trong tủ lạnh! 🎉", Toast.LENGTH_LONG).show()
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1.5f)
                            .height(48.dp)
                    ) {
                        Text("Múc luôn & Lên lịch 🍳", fontSize = 13.sp, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. DIALOG THÊM MỚI THỰC PHẨM THỦ CÔNG (CRUD - Create Ingredient dialog)
    // ==========================================
    if (showAddIngredientDialog) {
        ModalBottomSheet(
            onDismissRequest = { showAddIngredientDialog = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = Color.White,
            dragHandle = { BottomSheetDefaults.DragHandle(color = EmeraldPrimary) }
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .widthIn(max = 600.dp)
                    .align(Alignment.CenterHorizontally)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 24.dp)
                    .padding(top = 8.dp, bottom = 48.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Bơm thêm thực phẩm vào tủ lạnh 🧊",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black,
                    color = EmeraldDarkHead
                )

                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Tên thực phẩm:", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                    OutlinedTextField(
                        value = formName,
                        onValueChange = { formName = it },
                        placeholder = { Text("VD: Cà chua, Thịt bò, Cá hồi", fontSize = 13.sp) },
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = VibrantBorderMedium
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("add_ing_form_name"),
                        shape = RoundedCornerShape(10.dp)
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text("Emoji đại diện:", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                        OutlinedTextField(
                            value = formEmoji,
                            onValueChange = { formEmoji = it },
                            placeholder = { Text("VD: 🍅, 🥩, 🐟", fontSize = 13.sp) },
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = EmeraldPrimary,
                                unfocusedBorderColor = VibrantBorderMedium
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(10.dp)
                        )
                    }

                    Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text("Đơn vị số lượng:", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                        OutlinedTextField(
                            value = formUnit,
                            onValueChange = { formUnit = it },
                            placeholder = { Text("VD: g, ml, quả", fontSize = 13.sp) },
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = EmeraldPrimary,
                                unfocusedBorderColor = VibrantBorderMedium
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(10.dp)
                        )
                    }
                }

                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Mức số lượng:", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                    OutlinedTextField(
                        value = formQtyStr,
                        onValueChange = { formQtyStr = it },
                        placeholder = { Text("VD: 300", fontSize = 13.sp) },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = VibrantBorderMedium
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp)
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedButton(
                        onClick = { showAddIngredientDialog = false },
                        border = BorderStroke(1.dp, EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp)
                    ) {
                        Text("Đóng", fontSize = 13.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                    }

                    Button(
                        onClick = {
                            val qtyVal = formQtyStr.toFloatOrNull() ?: 100f
                            // Auto calculate calories/proteins or default them cleanly since fields are removed (Request 4)
                            val kcalVal = 60
                            val proVal = 5

                            if (formName.isBlank()) {
                                Toast.makeText(context, "Vui lòng nhập tên thực phẩm! ⚠️", Toast.LENGTH_SHORT).show()
                            } else {
                                val newIng = MealIngredient(
                                    name = formName,
                                    emoji = formEmoji.ifBlank { "🥦" },
                                    quantity = qtyVal,
                                    unit = formUnit.ifBlank { "g" },
                                    calories = kcalVal,
                                    protein = proVal
                                )
                                availableIngredients = availableIngredients + newIng
                                showAddIngredientDialog = false
                                
                                // Reset form references
                                formName = ""
                                formEmoji = "🥦"
                                formQtyStr = ""

                                Toast.makeText(context, "Bổ sung tủ lạnh thành công! 🧊🌿", Toast.LENGTH_SHORT).show()
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1.5f)
                            .height(48.dp)
                    ) {
                        Text("Lưu & Bơm thực phẩm 💾", fontSize = 13.sp, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

// Helpers for modifier fluid helper
private fun Modifier.fillWithSameWidth(fraction: Float = 1f): Modifier = this.fillMaxWidth(fraction)

// --- WORKOUT PLANNING SCREEN ---
// TÊN TÍNH NĂNG: QUẢN LÝ LỊCH TẬP THỂ DỤC HÀNG NGÀY (THƯ MỤC / TẬP TIN)
data class WorkoutItem(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val duration: Int,
    val isAutoGenerated: Boolean
)

data class TimeSlot(
    val id: String = java.util.UUID.randomUUID().toString(),
    val startTime: String,
    val endTime: String,
    val availableDuration: Int,
    val workouts: List<WorkoutItem> = emptyList()
)

data class DailyStats(
    val totalWorkoutTime: Int,
    val minRequiredTime: Int
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WorkoutScreen(viewModel: AppViewModel) {
    val context = LocalContext.current
    val weekdays = listOf("Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật")
    var selectedDay by remember { mutableStateOf("Thứ 2") }
    var minRequiredTime by remember { mutableStateOf(60) }

    var allDaysSlotsMap by remember {
        mutableStateOf(
            mapOf(
                "Thứ 2" to listOf(
                    TimeSlot(startTime = "06:00", endTime = "07:30", availableDuration = 90, workouts = listOf(WorkoutItem(name = "Chạy bộ sáng bờ hồ 🏃‍♂️", duration = 30, isAutoGenerated = false))),
                    TimeSlot(startTime = "17:30", endTime = "19:30", availableDuration = 120, workouts = emptyList())
                ),
                "Thứ 3" to listOf(
                    TimeSlot(startTime = "06:30", endTime = "07:30", availableDuration = 60, workouts = emptyList()),
                    TimeSlot(startTime = "16:45", endTime = "18:45", availableDuration = 120, workouts = listOf(WorkoutItem(name = "Bơi tự do giải stress 🏊‍♂️", duration = 45, isAutoGenerated = false)))
                ),
                "Thứ 4" to listOf(
                    TimeSlot(startTime = "06:15", endTime = "08:15", availableDuration = 120, workouts = listOf(WorkoutItem(name = "Yoga tĩnh tâm 🧘", duration = 45, isAutoGenerated = true))),
                    TimeSlot(startTime = "18:00", endTime = "19:30", availableDuration = 90, workouts = emptyList())
                ),
                "Thứ 5" to listOf(
                    TimeSlot(startTime = "17:00", endTime = "19:00", availableDuration = 120, workouts = listOf(WorkoutItem(name = "Đạp xe dạo quanh phố 🚴", duration = 45, isAutoGenerated = false)))
                ),
                "Thứ 6" to listOf(
                    TimeSlot(startTime = "17:30", endTime = "19:30", availableDuration = 120, workouts = listOf(WorkoutItem(name = "HIIT bứt cơ nhanh 🔥", duration = 45, isAutoGenerated = true)))
                ),
                "Thứ 7" to listOf(
                    TimeSlot(startTime = "15:00", endTime = "18:00", availableDuration = 180, workouts = listOf(WorkoutItem(name = "Đá bóng giao lưu ⚽", duration = 90, isAutoGenerated = false)))
                ),
                "Chủ Nhật" to listOf(
                    TimeSlot(startTime = "07:00", endTime = "09:30", availableDuration = 150, workouts = emptyList())
                )
            )
        )
    }

    val defaultPredefinedWorkouts = listOf(
        Pair("Chạy bộ sảng khoái 🏃‍♂️", 30),
        Pair("Đạp xe dạo hồ 🚴", 45),
        Pair("Yoga dẻo dai 🧘", 20),
        Pair("Tập Gym Cardio 🏋️‍♂️", 45),
        Pair("Nhảy dây đốt mỡ ⚡", 15),
        Pair("Bơi sải tự do 🏊‍♂️", 40)
    )

    val activeSlots = allDaysSlotsMap[selectedDay] ?: emptyList()
    val totalWorkoutTime = activeSlots.sumOf { slot -> slot.workouts.sumOf { it.duration } }
    val isGoalAchieved = totalWorkoutTime >= minRequiredTime

    var targetSlotForAdding by remember { mutableStateOf<TimeSlot?>(null) }
    var editingWorkoutPair by remember { mutableStateOf<Pair<TimeSlot, WorkoutItem>?>(null) }
    var showAddCustomSlotDialog by remember { mutableStateOf(false) }

    var manualWorkoutName by remember { mutableStateOf("") }
    var manualWorkoutDurationText by remember { mutableStateOf("30") }
    var isManualSectionExpanded by remember { mutableStateOf(false) }

    var editWorkoutName by remember { mutableStateOf("") }
    var editWorkoutDurationText by remember { mutableStateOf("30") }

    var newSlotStart by remember { mutableStateOf("17:00") }
    var newSlotEnd by remember { mutableStateOf("19:00") }

    val onTriggerAutoSchedule = {
        val slots = allDaysSlotsMap[selectedDay] ?: emptyList()
        var currentTotal = slots.sumOf { s -> s.workouts.sumOf { it.duration } }
        val goal = minRequiredTime

        val timeNeeded = goal - currentTotal
        if (timeNeeded <= 0) {
            Toast.makeText(context, "Chỉ tiêu đã hoàn thành xuất sắc! 🎉 (${currentTotal}/${goal}p)", Toast.LENGTH_SHORT).show()
        } else {
            var tempSlots = slots.map { it.copy(workouts = it.workouts.toList()) }
            var isProgressMade = true
            var itemsAdded = 0
            var minutesAdded = 0

            while (currentTotal < goal && isProgressMade) {
                isProgressMade = false
                for (i in tempSlots.indices) {
                    val slot = tempSlots[i]
                    val usedSpace = slot.workouts.sumOf { it.duration }
                    val remainingSpace = slot.availableDuration - usedSpace

                    if (remainingSpace > 0) {
                        val fitExercises = defaultPredefinedWorkouts.filter { it.second <= remainingSpace }
                        if (fitExercises.isNotEmpty()) {
                            val selectedExercise = fitExercises.random()
                            val newWorkout = WorkoutItem(
                                name = selectedExercise.first,
                                duration = selectedExercise.second,
                                isAutoGenerated = true
                            )
                            tempSlots = tempSlots.mapIndexed { idx, s ->
                                if (idx == i) s.copy(workouts = s.workouts + newWorkout) else s
                            }
                            currentTotal += selectedExercise.second
                            minutesAdded += selectedExercise.second
                            itemsAdded++
                            isProgressMade = true
                            if (currentTotal >= goal) break
                        }
                    }
                }
            }

            allDaysSlotsMap = allDaysSlotsMap.toMutableMap().apply { put(selectedDay, tempSlots) }

            if (itemsAdded > 0) {
                Toast.makeText(context, "Đã xếp thêm $itemsAdded môn (+ $minutesAdded phút) vào khung giờ trống! 🤖⚡", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(context, "Các khung giờ rảnh đều đã kín! Hãy tạo thêm khung rảnh mới. ⚠️", Toast.LENGTH_LONG).show()
            }
        }
    }

    val onCreateWorkoutInSlot: (String, String, Int, Boolean) -> Unit = { slotId, name, dur, isAuto ->
        allDaysSlotsMap = allDaysSlotsMap.toMutableMap().apply {
            val list = allDaysSlotsMap[selectedDay] ?: emptyList()
            val updated = list.map { slot ->
                if (slot.id == slotId) {
                    val usedSpace = slot.workouts.sumOf { it.duration }
                    val remainingSpace = slot.availableDuration - usedSpace
                    if (dur > remainingSpace) {
                        Toast.makeText(context, "Không đủ chỗ trống! (Còn ${remainingSpace}p trống)", Toast.LENGTH_LONG).show()
                        slot
                    } else {
                        val newItem = WorkoutItem(name = name, duration = dur, isAutoGenerated = isAuto)
                        Toast.makeText(context, "Thêm thành công môn '$name'!", Toast.LENGTH_SHORT).show()
                        slot.copy(workouts = slot.workouts + newItem)
                    }
                } else slot
            }
            put(selectedDay, updated)
        }
    }

    val onUpdateWorkoutInSlot: (String, String, String, Int) -> Unit = { slotId, workoutId, newName, newDur ->
        allDaysSlotsMap = allDaysSlotsMap.toMutableMap().apply {
            val list = allDaysSlotsMap[selectedDay] ?: emptyList()
            val updated = list.map { slot ->
                if (slot.id == slotId) {
                    val otherWorkoutsDurations = slot.workouts.filterNot { it.id == workoutId }.sumOf { it.duration }
                    val remainingSpace = slot.availableDuration - otherWorkoutsDurations
                    if (newDur > remainingSpace) {
                        Toast.makeText(context, "Sửa thất bại! Vượt quá giờ rảnh (${remainingSpace}p còn lại)", Toast.LENGTH_LONG).show()
                        slot
                    } else {
                        val updatedWorkouts = slot.workouts.map { wItem ->
                            if (wItem.id == workoutId) wItem.copy(name = newName, duration = newDur) else wItem
                        }
                        Toast.makeText(context, "Đã cập nhật bài tập! 📝", Toast.LENGTH_SHORT).show()
                        slot.copy(workouts = updatedWorkouts)
                    }
                } else slot
            }
            put(selectedDay, updated)
        }
    }

    val onDeleteWorkoutInSlot: (String, String) -> Unit = { slotId, workoutId ->
        allDaysSlotsMap = allDaysSlotsMap.toMutableMap().apply {
            val list = allDaysSlotsMap[selectedDay] ?: emptyList()
            val updated = list.map { slot ->
                if (slot.id == slotId) {
                    val removedWorkout = slot.workouts.find { it.id == workoutId }
                    Toast.makeText(context, "Đã xóa '${removedWorkout?.name ?: ""}' khỏi lịch! 🗑️", Toast.LENGTH_SHORT).show()
                    slot.copy(workouts = slot.workouts.filterNot { it.id == workoutId })
                } else slot
            }
            put(selectedDay, updated)
        }
    }

    val onCreateTimeSlot: (String, String) -> Unit = { start, end ->
        val duration = calculateDuration(start, end)
        if (duration <= 0) {
            Toast.makeText(context, "Giờ kết thúc phải lớn hơn giờ bắt đầu! ⚠️", Toast.LENGTH_SHORT).show()
        } else {
            val newSlot = TimeSlot(startTime = start, endTime = end, availableDuration = duration)
            allDaysSlotsMap = allDaysSlotsMap.toMutableMap().apply {
                val list = allDaysSlotsMap[selectedDay] ?: emptyList()
                put(selectedDay, list + newSlot)
            }
            Toast.makeText(context, "Đã thêm khung rảnh mới! 📁", Toast.LENGTH_SHORT).show()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
            .testTag("workout_schedule_screen")
    ) {
        Column {
            Text(text = "Lịch Trình Vận Động Tự Nhiên 🏃‍♂️", fontSize = 18.sp, fontWeight = FontWeight.Black, color = EmeraldDarkHead)
            Text(text = "Mô phỏng Quản lý Thư mục (Khung rảnh) và Tập tin (Bài tập) trực quan.", fontSize = 11.sp, color = TextLight)
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState())
                .padding(vertical = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            weekdays.forEach { dayName ->
                val isSelected = selectedDay == dayName
                val totalMins = allDaysSlotsMap[dayName]?.sumOf { s -> s.workouts.sumOf { w -> w.duration } } ?: 0

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(16.dp))
                        .background(if (isSelected) VibrantPrimary else Color.White)
                        .border(BorderStroke(1.dp, if (isSelected) VibrantPrimary else VibrantBorderMedium), RoundedCornerShape(16.dp))
                        .clickable { selectedDay = dayName }
                        .padding(horizontal = 14.dp, vertical = 10.dp)
                        .testTag("day_selector_$dayName")
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(text = dayName, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = if (isSelected) Color.White else VibrantTextDark)
                        if (totalMins > 0) {
                            Box(
                                modifier = Modifier
                                    .clip(CircleShape)
                                    .background(if (isSelected) Color.White.copy(alpha = 0.25f) else VibrantPrimary.copy(alpha = 0.15f))
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(text = "${totalMins}p", fontSize = 9.sp, fontWeight = FontWeight.Black, color = if (isSelected) Color.White else VibrantPrimary)
                            }
                        }
                    }
                }
            }
        }

        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = if (isGoalAchieved) Color(0xFFE8F5E9) else Color.White),
            border = BorderStroke(width = 1.dp, color = if (isGoalAchieved) Color(0xFF2E7D32) else VibrantBorderMedium),
            modifier = Modifier.fillMaxWidth().padding(bottom = 14.dp).testTag("stats_box_card")
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                    Column {
                        Text(text = if (isGoalAchieved) "🏆 ĐÃ ĐẠT CHỈ TIÊU!" else "📊 Chỉ Tiêu Rèn Luyện Trong Ngày", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = if (isGoalAchieved) Color(0xFF1B5E20) else VibrantTextDark)
                        Text(text = "Tổng: ${totalWorkoutTime}p / Tối thiểu: ${minRequiredTime}p", fontSize = 11.5.sp, color = if (isGoalAchieved) Color(0xFF2E7D32) else TextLight)
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))
                val progressValue = if (minRequiredTime > 0) (totalWorkoutTime.toFloat() / minRequiredTime.toFloat()).coerceAtMost(1f) else 0f
                val animatedProgress by animateFloatAsState(targetValue = progressValue, label = "progress")
                LinearProgressIndicator(
                    progress = { animatedProgress },
                    color = if (isGoalAchieved) Color(0xFF2E7D32) else VibrantPrimary,
                    trackColor = if (isGoalAchieved) Color(0xFFC8E6C9) else LightGrey,
                    modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp))
                )

                Spacer(modifier = Modifier.height(10.dp))
                Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(text = "Cài mục tiêu:", fontSize = 10.5.sp, color = VibrantTextMedium)
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        listOf(30, 45, 60, 90).forEach { targetValue ->
                            val isTargetSel = minRequiredTime == targetValue
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(if (isTargetSel) VibrantPrimary else LightGrey)
                                    .clickable { minRequiredTime = targetValue }
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Text(text = "${targetValue}p", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = if (isTargetSel) Color.White else VibrantTextDark)
                            }
                        }
                    }
                }
            }
        }

        Button(
            onClick = onTriggerAutoSchedule,
            colors = ButtonDefaults.buttonColors(containerColor = VibrantPrimary),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth().height(48.dp).padding(bottom = 8.dp).testTag("auto_schedule_main_btn")
        ) {
            Text("⚡ Auto Xếp Lịch AI", fontSize = 12.sp, fontWeight = FontWeight.Bold)
        }

        Spacer(modifier = Modifier.height(6.dp))
        Text(text = "📂 Thư mục Khung giờ rảnh:", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark, modifier = Modifier.padding(bottom = 6.dp))

        if (activeSlots.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White, RoundedCornerShape(16.dp))
                    .border(BorderStroke(1.dp, VibrantBorderMedium), RoundedCornerShape(16.dp))
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(text = "Chưa có khung giờ rảnh nào được tạo.", fontSize = 12.sp, color = VibrantTextLight, textAlign = TextAlign.Center)
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                activeSlots.forEach { slot ->
                    val usedTime = slot.workouts.sumOf { it.duration }
                    val remainingTime = slot.availableDuration - usedTime

                    Card(
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, VibrantBorderMedium),
                        modifier = Modifier.fillMaxWidth().testTag("timeslot_card_${slot.id}")
                    ) {
                        Column(modifier = Modifier.padding(12.dp)) {
                            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                    Text("📁", fontSize = 16.sp)
                                    Column {
                                        Text(text = "Rảnh: ${slot.startTime} - ${slot.endTime}", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                                        Text(text = "Tổng: ${slot.availableDuration}p • Trống: ${remainingTime}p", fontSize = 10.sp, color = VibrantTextMedium)
                                    }
                                }

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Box(
                                        modifier = Modifier
                                            .clip(RoundedCornerShape(6.dp))
                                            .background(VibrantPrimary.copy(alpha = 0.12f))
                                            .clickable { targetSlotForAdding = slot }
                                            .padding(horizontal = 6.dp, vertical = 4.dp)
                                            .testTag("add_workout_to_slot_${slot.id}")
                                    ) {
                                        Text(text = "+ Thêm", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = VibrantPrimary)
                                    }
                                }
                            }

                            if (slot.workouts.isNotEmpty()) {
                                Spacer(modifier = Modifier.height(8.dp))
                                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                    slot.workouts.forEach { item ->
                                        Row(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .clip(RoundedCornerShape(8.dp))
                                                .background(VibrantBackground)
                                                .border(BorderStroke(1.dp, VibrantBorderLight), RoundedCornerShape(8.dp))
                                                .padding(horizontal = 8.dp, vertical = 6.dp)
                                                .testTag("workout_item_${item.id}"),
                                            verticalAlignment = Alignment.CenterVertically,
                                            horizontalArrangement = Arrangement.SpaceBetween
                                        ) {
                                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp), modifier = Modifier.weight(1f)) {
                                                Text("📄", fontSize = 12.sp)
                                                Column {
                                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                                        Text(text = item.name, fontSize = 11.5.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                                                        Text(
                                                            text = if (item.isAutoGenerated) "🤖 AI" else "✏️ Tay",
                                                            fontSize = 8.sp,
                                                            color = if (item.isAutoGenerated) VibrantPrimary else Color(0xFFEF6C00),
                                                            modifier = Modifier
                                                                .background(if (item.isAutoGenerated) VibrantPrimary.copy(alpha = 0.12f) else Color(0xFFFFE0B2), RoundedCornerShape(3.dp))
                                                                .padding(horizontal = 3.dp, vertical = 1.dp)
                                                        )
                                                    }
                                                    Text(text = "Thời lượng: ${item.duration}p", fontSize = 10.sp, color = VibrantTextMedium)
                                                }
                                            }

                                            Row {
                                                IconButton(
                                                    onClick = {
                                                        editWorkoutName = item.name
                                                        editWorkoutDurationText = item.duration.toString()
                                                        editingWorkoutPair = Pair(slot, item)
                                                    },
                                                    modifier = Modifier.size(26.dp).testTag("edit_workout_${item.id}")
                                                ) {
                                                    Icon(imageVector = Icons.Filled.Edit, contentDescription = "Edit", tint = VibrantPrimary, modifier = Modifier.size(12.dp))
                                                }

                                                IconButton(
                                                    onClick = { onDeleteWorkoutInSlot(slot.id, item.id) },
                                                    modifier = Modifier.size(26.dp).testTag("delete_workout_${item.id}")
                                                ) {
                                                    Icon(imageVector = Icons.Filled.Delete, contentDescription = "Delete", tint = VibrantAlertCoral, modifier = Modifier.size(12.dp))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))
        Button(
            onClick = { showAddCustomSlotDialog = true },
            colors = ButtonDefaults.buttonColors(containerColor = Color.White),
            border = BorderStroke(1.dp, VibrantBorderMedium),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth().height(44.dp).testTag("add_custom_timeslot_folder_btn")
        ) {
            Text(text = "📁 Tạo thêm Khung giờ rảnh (Folder)", fontSize = 11.5.sp, color = VibrantTextDark)
        }
        Spacer(modifier = Modifier.height(20.dp))
    }

    targetSlotForAdding?.let { slot ->
        val usedSpace = slot.workouts.sumOf { it.duration }
        val remainingSpace = slot.availableDuration - usedSpace

        ModalBottomSheet(
            onDismissRequest = { targetSlotForAdding = null; isManualSectionExpanded = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = Color.White,
            dragHandle = { BottomSheetDefaults.DragHandle(color = EmeraldPrimary) }
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .widthIn(max = 600.dp)
                    .align(Alignment.CenterHorizontally)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 24.dp)
                    .padding(top = 8.dp, bottom = 48.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Thêm Bài Tập Rèn Luyện 🏃‍♂️",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black,
                    color = EmeraldDarkHead
                )

                Text(
                    text = "Còn trống ${remainingSpace}p trong khung giờ ${slot.startTime} - ${slot.endTime}",
                    fontSize = 12.sp,
                    color = VibrantTextMedium
                )

                Text(
                    text = "QUYẾT NHANH ĐỀ XUẤT TIỆN LỢI:",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = VibrantTextDark
                )

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    defaultPredefinedWorkouts.chunked(2).forEach { pairList ->
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            pairList.forEach { (exName, exDur) ->
                                val canFit = exDur <= remainingSpace
                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(if (canFit) VibrantBackground else LightGrey.copy(alpha = 0.5f))
                                        .border(
                                            1.dp,
                                            if (canFit) EmeraldPrimary.copy(alpha = 0.15f) else Color.Transparent,
                                            RoundedCornerShape(12.dp)
                                        )
                                        .clickable(enabled = canFit) {
                                            onCreateWorkoutInSlot(slot.id, exName, exDur, false)
                                            targetSlotForAdding = null
                                        }
                                        .padding(vertical = 12.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = "$exName (${exDur}p)",
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = if (canFit) VibrantTextDark else VibrantTextLight
                                    )
                                }
                            }
                        }
                    }
                }

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { isManualSectionExpanded = !isManualSectionExpanded }
                        .padding(vertical = 4.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (isManualSectionExpanded) "🔽 Thôi nhập thủ công" else "▶️ Nhập môn tự do thủ công",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = EmeraldPrimary
                    )
                }

                if (isManualSectionExpanded) {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        OutlinedTextField(
                            value = manualWorkoutName,
                            onValueChange = { manualWorkoutName = it },
                            label = { Text("Tên môn rèn luyện", color = VibrantTextMedium) },
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = EmeraldPrimary,
                                unfocusedBorderColor = VibrantBorderMedium
                            ),
                            shape = RoundedCornerShape(10.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("manual_workout_name_input")
                        )

                        OutlinedTextField(
                            value = manualWorkoutDurationText,
                            onValueChange = { manualWorkoutDurationText = it },
                            label = { Text("Thời lượng (phút)", color = VibrantTextMedium) },
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = EmeraldPrimary,
                                unfocusedBorderColor = VibrantBorderMedium
                            ),
                            shape = RoundedCornerShape(10.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("manual_workout_duration_input")
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedButton(
                        onClick = { targetSlotForAdding = null; isManualSectionExpanded = false },
                        border = BorderStroke(1.dp, EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp)
                    ) {
                        Text("Bỏ qua", fontSize = 13.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                    }

                    Button(
                        enabled = !isManualSectionExpanded || manualWorkoutName.isNotBlank(),
                        onClick = {
                            if (isManualSectionExpanded) {
                                val dur = manualWorkoutDurationText.toIntOrNull() ?: 30
                                if (manualWorkoutName.isBlank()) {
                                    Toast.makeText(context, "Đặt tên môn tập!", Toast.LENGTH_SHORT).show()
                                } else {
                                    onCreateWorkoutInSlot(slot.id, manualWorkoutName, dur, false)
                                    targetSlotForAdding = null
                                    manualWorkoutName = ""
                                    isManualSectionExpanded = false
                                }
                            } else {
                                targetSlotForAdding = null
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1.2f)
                            .height(48.dp)
                    ) {
                        Text("Lưu kết quả 💾", fontSize = 13.sp, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }

    editingWorkoutPair?.let { pair ->
        val slot = pair.first
        val workout = pair.second

        ModalBottomSheet(
            onDismissRequest = { editingWorkoutPair = null },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = Color.White,
            dragHandle = { BottomSheetDefaults.DragHandle(color = EmeraldPrimary) }
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .widthIn(max = 600.dp)
                    .align(Alignment.CenterHorizontally)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 24.dp)
                    .padding(top = 8.dp, bottom = 48.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Chỉnh Sửa Lịch Tập 📝",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black,
                    color = EmeraldDarkHead
                )

                OutlinedTextField(
                    value = editWorkoutName,
                    onValueChange = { editWorkoutName = it },
                    label = { Text("Tên môn rèn luyện", color = VibrantTextMedium) },
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = EmeraldPrimary,
                        unfocusedBorderColor = VibrantBorderMedium
                    ),
                    shape = RoundedCornerShape(10.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("edit_workout_name_input")
                )

                OutlinedTextField(
                    value = editWorkoutDurationText,
                    onValueChange = { editWorkoutDurationText = it },
                    label = { Text("Thời lượng (phút)", color = VibrantTextMedium) },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = EmeraldPrimary,
                        unfocusedBorderColor = VibrantBorderMedium
                    ),
                    shape = RoundedCornerShape(10.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("edit_workout_duration_input")
                )

                Spacer(modifier = Modifier.height(12.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedButton(
                        onClick = { editingWorkoutPair = null },
                        border = BorderStroke(1.dp, EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp)
                    ) {
                        Text("Bỏ qua", fontSize = 13.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                    }

                    Button(
                        onClick = {
                            val dur = editWorkoutDurationText.toIntOrNull() ?: 30
                            if (editWorkoutName.isBlank()) {
                                Toast.makeText(context, "Môn không bỏ trống!", Toast.LENGTH_SHORT).show()
                            } else {
                                onUpdateWorkoutInSlot(slot.id, workout.id, editWorkoutName, dur)
                                editingWorkoutPair = null
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1.5f)
                            .height(48.dp)
                            .testTag("edit_workout_save_btn")
                    ) {
                        Text("Xác nhận Lưu 💾", fontSize = 13.sp, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }

    if (showAddCustomSlotDialog) {
        ModalBottomSheet(
            onDismissRequest = { showAddCustomSlotDialog = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = Color.White,
            dragHandle = { BottomSheetDefaults.DragHandle(color = EmeraldPrimary) }
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .widthIn(max = 600.dp)
                    .align(Alignment.CenterHorizontally)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 24.dp)
                    .padding(top = 8.dp, bottom = 48.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Tạo Khung Giờ Mới (📁 Thư mục)",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black,
                    color = EmeraldDarkHead
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    OutlinedTextField(
                        value = newSlotStart,
                        onValueChange = { newSlotStart = it },
                        label = { Text("Bắt đầu (HH:mm)", color = VibrantTextMedium) },
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = VibrantBorderMedium
                        ),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("new_slot_start_input")
                    )

                    OutlinedTextField(
                        value = newSlotEnd,
                        onValueChange = { newSlotEnd = it },
                        label = { Text("Kết thúc (HH:mm)", color = VibrantTextMedium) },
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = VibrantBorderMedium
                        ),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("new_slot_end_input")
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedButton(
                        onClick = { showAddCustomSlotDialog = false },
                        border = BorderStroke(1.dp, EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp)
                    ) {
                        Text("Bỏ qua", fontSize = 13.sp, color = EmeraldPrimary, fontWeight = FontWeight.Bold)
                    }

                    Button(
                        onClick = {
                            if (!isValidTimeFormat(newSlotStart) || !isValidTimeFormat(newSlotEnd)) {
                                Toast.makeText(context, "Nhập đúng định dạng HH:mm!", Toast.LENGTH_SHORT).show()
                            } else {
                                onCreateTimeSlot(newSlotStart, newSlotEnd)
                                showAddCustomSlotDialog = false
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1.5f)
                            .height(48.dp)
                            .testTag("save_new_slot_btn")
                    ) {
                        Text("Tạo Khung Giờ 💾", fontSize = 13.sp, color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

// ----------------------------------------------------
// ĐỊNH NGHĨA CÁC THUẬT TOÁN HỖ TRỢ VÀ TIỆN ÍCH THỜI GIAN
// ----------------------------------------------------

/**
 * Kiểm tra định dạng thời gian nhập HH:mm có hợp lệ không
 */
fun isValidTimeFormat(timeStr: String): Boolean {
    val regex = """^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$""".toRegex()
    return regex.matches(timeStr)
}

/**
 * Chuyển đổi chuỗi "HH:mm" thành tổng số phút kể từ đầu ngày
 */
fun parseTimeToMinutes(timeStr: String): Int {
    return try {
        val parts = timeStr.split(":")
        val h = parts[0].trim().toInt()
        val m = parts[1].trim().toInt()
        h * 60 + m
    } catch (e: Exception) {
        0
    }
}

/**
 * Chuyển đổi số phút kể từ đầu ngày thành chuỗi dạng "HH:mm"
 */
fun formatMinutesToTime(totalMinutes: Int): String {
    val h = (totalMinutes / 60) % 24
    val m = totalMinutes % 60
    return String.format("%02d:%02d", h, m)
}

/**
 * Tính toán độ rộng/độ chu kỳ tập luyện (số phút) giữa hai mốc thời gian dạng HH:mm
 */
fun calculateDuration(start: String, end: String): Int {
    val startMin = parseTimeToMinutes(start)
    val endMin = parseTimeToMinutes(end)
    return if (endMin >= startMin) {
        endMin - startMin
    } else {
        (24 * 60 - startMin) + endMin // Vượt qua mốc nửa đêm
    }
}

// --- PROFILE SCREEN ---
@Composable
fun ProfileScreen(viewModel: AppViewModel) {
    val context = LocalContext.current
    val profile by viewModel.profileState.collectAsStateWithLifecycle()
    val workouts by viewModel.workoutsState.collectAsStateWithLifecycle()
    val isTeenager = (profile?.age ?: 22) < 18

    var isEditing by rememberSaveable { mutableStateOf(false) }

    var weightText by remember { mutableStateOf("") }
    var heightText by remember { mutableStateOf("") }
    var ageText by remember { mutableStateOf("") }
    var selectedGoal by remember { mutableStateOf("Giữ cân") }
    var dietaryRestrictionsText by remember { mutableStateOf("") }

    // Settings States (stored as remembers but can be updated interactively)
    var isWaterReminderEnabled by rememberSaveable { mutableStateOf(true) }
    var isAiCompanionEnabled by rememberSaveable { mutableStateOf(true) }
    var isWorkoutAlertEnabled by rememberSaveable { mutableStateOf(true) }

    // Dialog confirmation states
    var showDeleteMealsDialog by rememberSaveable { mutableStateOf(false) }
    var showDeleteFoodsDialog by rememberSaveable { mutableStateOf(false) }
    var showDeleteWorkoutsDialog by rememberSaveable { mutableStateOf(false) }
    var showResetAllDialog by rememberSaveable { mutableStateOf(false) }

    // Sync profile to states once loaded / reset
    LaunchedEffect(profile) {
        profile?.let {
            weightText = it.weight.toString()
            heightText = it.height.toString()
            ageText = it.age.toString()
            selectedGoal = it.healthGoal
            dietaryRestrictionsText = it.dietaryRestrictions
        }
    }

    // Confirmation dialogs
    if (showDeleteMealsDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteMealsDialog = false },
            title = { Text("Xác nhận xoá", color = Color.Black, fontWeight = FontWeight.Bold) },
            text = { Text("Bạn có chắc chắn muốn xoá toàn bộ lịch sử các món ăn đã ghi nhận?", color = Color.Black) },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.clearAllMeals()
                        showDeleteMealsDialog = false
                        Toast.makeText(context, "Đã xoá toàn bộ thực đơn đã ghi nhận!", Toast.LENGTH_SHORT).show()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = VibrantAlertCoral)
                ) {
                    Text("Xoá sạch", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteMealsDialog = false }) {
                    Text("Huỷ", color = Color.Black)
                }
            }
        )
    }

    if (showDeleteFoodsDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteFoodsDialog = false },
            title = { Text("Xác nhận xoá", color = Color.Black, fontWeight = FontWeight.Bold) },
            text = { Text("Bạn có chắc chắn muốn xoá danh sách các món ăn quét & phân tích nhãn?", color = Color.Black) },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.clearAllBoughtFoods()
                        showDeleteFoodsDialog = false
                        Toast.makeText(context, "Đã xoá lịch sử quét thực phẩm thành công!", Toast.LENGTH_SHORT).show()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = VibrantAlertCoral)
                ) {
                    Text("Xoá sạch", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteFoodsDialog = false }) {
                    Text("Huỷ", color = Color.Black)
                }
            }
        )
    }

    if (showDeleteWorkoutsDialog) {
        AlertDialog(
            onDismissRequest = { showDeleteWorkoutsDialog = false },
            title = { Text("Xác nhận xoá", color = Color.Black, fontWeight = FontWeight.Bold) },
            text = { Text("Bạn có chắc chắn muốn xoá sạch toàn bộ lịch trình các bài luyện tập?", color = Color.Black) },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.clearAllWorkouts()
                        showDeleteWorkoutsDialog = false
                        Toast.makeText(context, "Đã xoá sạch lịch trình rèn luyện!", Toast.LENGTH_SHORT).show()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = VibrantAlertCoral)
                ) {
                    Text("Xoá sạch", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteWorkoutsDialog = false }) {
                    Text("Huỷ", color = Color.Black)
                }
            }
        )
    }

    if (showResetAllDialog) {
        AlertDialog(
            onDismissRequest = { showResetAllDialog = false },
            title = { Text("Khôi phục cài đặt gốc", color = Color.Black, fontWeight = FontWeight.Bold) },
            text = { Text("Tác vụ này sẽ đặt lại Hồ sơ về mặc định, xoá sạch lịch sử thực đơn, món ăn đã quét và bài tập luyện tập. Hành động này không thể hoàn tác!", color = Color.Black) },
            confirmButton = {
                Button(
                    onClick = {
                        // Reset Profile
                        viewModel.updateProfile(60f, 165f, 22, "Giữ cân", "")
                        // Clear Tables
                        viewModel.clearAllMeals()
                        viewModel.clearAllBoughtFoods()
                        viewModel.clearAllWorkouts()
                        
                        showResetAllDialog = false
                        Toast.makeText(context, "Đã khôi phục cài đặt gốc thành công!", Toast.LENGTH_LONG).show()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
                ) {
                    Text("Khôi phục", color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { showResetAllDialog = false }) {
                    Text("Huỷ", color = Color.Black)
                }
            }
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(20.dp)
    ) {
        Text(
            text = "Hồ Sơ Sức Khoẻ Cá Nhân 👤",
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            color = Color.Black,
            modifier = Modifier.padding(bottom = 4.dp)
        )
        Text(
            text = "Quản lý chỉ số cơ thể, mục tiêu rèn luyện và cá nhân hóa các thiết lập ứng dụng.",
            fontSize = 12.sp,
            color = Color.Black.copy(alpha = 0.8f),
            modifier = Modifier.padding(bottom = 16.dp)
        )

        // Safety warning alert for children (Under 18 Check) (Relocated to ProfileScreen)
        if (isTeenager) {
            Card(
                colors = CardDefaults.cardColors(containerColor = VibrantAlertCoral.copy(alpha = 0.08f)),
                border = BorderStroke(1.dp, VibrantAlertCoral.copy(alpha = 0.2f)),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp)
                    .testTag("teenager_safety_alert_banner")
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Warning,
                        contentDescription = "Adolescent Warning",
                        tint = VibrantAlertCoral,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "Bạn đang ở độ tuổi phát triển (<18 tuổi). Xin hãy tham khảo ý kiến của cha mẹ hoặc bác sĩ dinh dưỡng trước khi thay đổi mục tiêu calo để phát triển an toàn toàn diện.",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = VibrantTextDark,
                        lineHeight = 16.sp
                    )
                }
            }
        }

        // CARD PROFILE INFO / FORM
        if (!isEditing) {
            // READ-ONLY PROFILE DASHBOARD
            Card(
                colors = CardDefaults.cardColors(containerColor = Color.White),
                border = BorderStroke(1.dp, LightGrey),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Thông Tin Thể Trạng Hiện Tại 📊",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.Black
                        )
                        IconButton(
                            onClick = { isEditing = true },
                            modifier = Modifier.size(28.dp).background(VibrantLightHighlight, CircleShape)
                        ) {
                            Icon(
                                imageVector = Icons.Filled.Edit,
                                contentDescription = "Chỉnh sửa",
                                tint = EmeraldPrimary,
                                modifier = Modifier.size(14.dp)
                            )
                        }
                    }

                    Divider(color = LightGrey.copy(alpha = 0.7f), thickness = 1.dp)

                    // Display user stats in grid-like rows with black high-contrast values
                    Row(modifier = Modifier.fillMaxWidth()) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("CÂN NẶNG", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.Black.copy(alpha = 0.6f))
                            Text("${profile?.weight ?: 60f} kg", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                        }
                        Column(modifier = Modifier.weight(1f)) {
                            Text("CHIỀU CAO", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.Black.copy(alpha = 0.6f))
                            Text("${profile?.height ?: 165f} cm", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                        }
                        Column(modifier = Modifier.weight(1f)) {
                            Text("TUỔI", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.Black.copy(alpha = 0.6f))
                            Text("${profile?.age ?: 22} tuổi", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                        }
                    }

                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("MỤC TIÊU SỨC KHOẺ", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.Black.copy(alpha = 0.6f))
                            Spacer(modifier = Modifier.height(4.dp))
                            Box(
                                modifier = Modifier
                                    .background(VibrantLightHighlight, RoundedCornerShape(6.dp))
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = profile?.healthGoal ?: "Giữ cân",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.Black
                                )
                            }
                        }
                        Column(modifier = Modifier.weight(1.5f)) {
                            Text("HẠN CHẾ ĂN UỐNG / DỊ ỨNG", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.Black.copy(alpha = 0.6f))
                            Spacer(modifier = Modifier.height(4.dp))
                            val restrict = profile?.dietaryRestrictions
                            Text(
                                text = if (restrict.isNullOrBlank()) "Không có dị ứng hay hạn chế nào 🎉" else restrict,
                                fontSize = 11.sp,
                                color = Color.Black,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(2.dp))

                    OutlinedButton(
                        onClick = { isEditing = true },
                        modifier = Modifier.fillMaxWidth(),
                        border = BorderStroke(1.dp, EmeraldPrimary),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = EmeraldPrimary),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Icon(imageVector = Icons.Filled.Edit, contentDescription = null, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("Chỉnh Sửa Chỉ Số Hồ Sơ", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                    }
                }
            }
        } else {
            // EDITABLE PROFILE FORM
            Card(
                colors = CardDefaults.cardColors(containerColor = Color.White),
                border = BorderStroke(1.dp, LightGrey),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(
                        text = "Chỉnh Sửa Chỉ Số Thể Trạng 📝",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.Black
                    )

                    // Weight input
                    OutlinedTextField(
                        value = weightText,
                        onValueChange = { weightText = it },
                        label = { Text("Cân nặng hiện tại (kg)", color = Color.Black) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.Black,
                            unfocusedTextColor = Color.Black,
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = LightGrey,
                            focusedLabelColor = Color.Black,
                            unfocusedLabelColor = Color.Black.copy(alpha = 0.7f)
                        ),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth().testTag("profile_weight_input"),
                        shape = RoundedCornerShape(10.dp)
                    )

                    // Height input
                    OutlinedTextField(
                        value = heightText,
                        onValueChange = { heightText = it },
                        label = { Text("Chiều cao (cm)", color = Color.Black) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.Black,
                            unfocusedTextColor = Color.Black,
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = LightGrey,
                            focusedLabelColor = Color.Black,
                            unfocusedLabelColor = Color.Black.copy(alpha = 0.7f)
                        ),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth().testTag("profile_height_input"),
                        shape = RoundedCornerShape(10.dp)
                    )

                    // Age input
                    OutlinedTextField(
                        value = ageText,
                        onValueChange = { ageText = it },
                        label = { Text("Độ tuổi của bạn", color = Color.Black) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.Black,
                            unfocusedTextColor = Color.Black,
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = LightGrey,
                            focusedLabelColor = Color.Black,
                            unfocusedLabelColor = Color.Black.copy(alpha = 0.7f)
                        ),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth().testTag("profile_age_input"),
                        shape = RoundedCornerShape(10.dp)
                    )

                    // Goal pills
                    Text(text = "Mục tiêu ăn uống & rèn luyện:", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        val goals = listOf("Giảm cân", "Giữ cân", "Tăng cân")
                        goals.forEach { goal ->
                            val isSel = selectedGoal == goal
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(if (isSel) EmeraldPrimary else LightGrey)
                                    .clickable { selectedGoal = goal }
                                    .padding(vertical = 8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    goal,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = if (isSel) Color.White else Color.Black
                                )
                            }
                        }
                    }

                    // Dietary Restrictions
                    OutlinedTextField(
                        value = dietaryRestrictionsText,
                        onValueChange = { dietaryRestrictionsText = it },
                        label = { Text("Hạn chế ăn uống (Không hành, dị ứng...)", color = Color.Black) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.Black,
                            unfocusedTextColor = Color.Black,
                            focusedBorderColor = EmeraldPrimary,
                            unfocusedBorderColor = LightGrey,
                            focusedLabelColor = Color.Black,
                            unfocusedLabelColor = Color.Black.copy(alpha = 0.7f)
                        ),
                        modifier = Modifier.fillMaxWidth().testTag("profile_restrictions_input"),
                        shape = RoundedCornerShape(10.dp)
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        OutlinedButton(
                            onClick = {
                                // Cancel and restore from profile
                                profile?.let {
                                    weightText = it.weight.toString()
                                    heightText = it.height.toString()
                                    ageText = it.age.toString()
                                    selectedGoal = it.healthGoal
                                    dietaryRestrictionsText = it.dietaryRestrictions
                                }
                                isEditing = false
                            },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(10.dp),
                            border = BorderStroke(1.dp, Color.Black)
                        ) {
                            Text("Huỷ", fontSize = 11.sp, color = Color.Black)
                        }

                        Button(
                            onClick = {
                                val wt = weightText.toFloatOrNull() ?: 60f
                                val ht = heightText.toFloatOrNull() ?: 165f
                                val ag = ageText.toIntOrNull() ?: 22
                                viewModel.updateProfile(wt, ht, ag, selectedGoal, dietaryRestrictionsText)
                                isEditing = false
                                Toast.makeText(context, "Đã lưu thông tin hồ sơ mới!", Toast.LENGTH_SHORT).show()
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                            modifier = Modifier.weight(1.5f).testTag("profile_save_button"),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Text("Lưu Thay Đổi 💾", fontSize = 11.sp, color = Color.White, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Target outputs indicators card
        profile?.let {
            val status = calculateHealthStatus(it)
            Card(
                colors = CardDefaults.cardColors(containerColor = EmeraldLightBg),
                modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp)
            ) {
                Column(modifier = Modifier.padding(14.dp)) {
                    Text(
                        "Đánh giá & Chỉ Số Luyện Tập Khuyên Dùng:",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.Black
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("• Chỉ số Khối Cơ Thể BMI: ${String.format("%.1f", status.bmi)} (${status.bmiCategory})", fontSize = 12.sp, color = Color.Black)
                    Text("• Tỷ lệ Trao Đổi Chất (BMR): ${status.bmr} Kcal / Ngày", fontSize = 12.sp, color = Color.Black)
                    Text("• Thời gian Tập Luyện Tối Thiểu: Khuyên Tập Ít Nhất ${status.minDailyExerciseMins} Phút / Ngày", fontSize = 12.sp, color = Color.Black, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(status.evaluationMessage, fontSize = 11.sp, color = Color.Black.copy(alpha = 0.9f))
                }
            }

            Card(
                colors = CardDefaults.cardColors(containerColor = EmeraldLightBg),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(14.dp)) {
                    Text(
                        "Dinh Dưỡng Đề Xuất Dựa Trên Thể Trạng:",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.Black
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("• Target Năng lượng: ${it.targetCalories} Kcal / Ngày", fontSize = 12.sp, color = Color.Black)
                    Text("• Target Chất Đạm (Protein): ${it.targetProtein} g / Ngày", fontSize = 12.sp, color = Color.Black)
                    Text("• Target Tinh bột (Carbs): ${it.targetCarbs} g / Ngày", fontSize = 12.sp, color = Color.Black)
                    Text("• Target Chất béo (Fat): ${it.targetFat} g / Ngày", fontSize = 12.sp, color = Color.Black)
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        "Dữ liệu mang tính gợi ý thiết thực để nuôi dưỡng thói quen tự nhiên dẻo dai.",
                        fontSize = 10.sp,
                        color = Color.Black.copy(alpha = 0.8f),
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            // Relocated Health Assessment Cardio Progress
            val completedDuration = workouts.filter { it.isCompleted }.sumOf { it.duration }
            val completionRatio = if (status.minDailyExerciseMins > 0) {
                completedDuration.toFloat() / status.minDailyExerciseMins.toFloat()
            } else 0f

            Spacer(modifier = Modifier.height(12.dp))

            Card(
                colors = CardDefaults.cardColors(containerColor = Color.White),
                border = BorderStroke(1.dp, LightGrey),
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("health_evaluation_profile_card")
            ) {
                Column(modifier = Modifier.padding(14.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text("🩺", fontSize = 16.sp)
                            Text(
                                text = "Tiến Trình Đạt Chuẩn Vận Động",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.Black
                            )
                        }

                        if (completedDuration >= status.minDailyExerciseMins) {
                            Text(
                                text = "ĐẠT CHUẨN ✅",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                color = EmeraldPrimary,
                                modifier = Modifier
                                    .background(VibrantLightHighlight, RoundedCornerShape(8.dp))
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            )
                        } else {
                            Text(
                                text = "CẦN TẬP THÊM 🏃‍♂️",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                color = VibrantAlertCoral,
                                modifier = Modifier
                                    .background(VibrantAlertCoral.copy(alpha = 0.1f), RoundedCornerShape(8.dp))
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Đã rèn luyện hôm nay:",
                            fontSize = 11.sp,
                            color = Color.Black.copy(alpha = 0.7f)
                        )
                        Text(
                            text = "$completedDuration / ${status.minDailyExerciseMins} phút",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = EmeraldPrimary
                        )
                    }

                    Spacer(modifier = Modifier.height(6.dp))

                    // Progress Bar
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .clip(RoundedCornerShape(4.dp))
                            .background(LightGrey)
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxHeight()
                                .fillMaxWidth(completionRatio.coerceIn(0f, 1f))
                                .background(EmeraldPrimary)
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // --- PREFERENCES & SETTINGS SECTION ---
        Text(
            text = "Cài Đặt & Tiện Ích ⚙️",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = Color.Black,
            modifier = Modifier.padding(bottom = 6.dp)
        )
        Text(
            text = "Bật tắt thông báo từ hệ thống và dọn dẹp bộ nhớ cơ sở dữ liệu dẻo dai.",
            fontSize = 11.sp,
            color = Color.Black.copy(alpha = 0.8f),
            modifier = Modifier.padding(bottom = 12.dp)
        )

        Card(
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = BorderStroke(1.dp, LightGrey),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                // Water Reminder toggle
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Nhắc nhở uống nước hằng giờ 💧",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.Black
                        )
                        Text(
                            text = "Gửi cảnh báo uống nước để duy trì thanh lọc cơ thể dẻo khi vận động.",
                            fontSize = 10.sp,
                            color = Color.Black.copy(alpha = 0.7f)
                        )
                    }
                    Switch(
                        checked = isWaterReminderEnabled,
                        onCheckedChange = {
                            isWaterReminderEnabled = it
                            val statusStr = if (it) "BẬT" else "TẮT"
                            Toast.makeText(context, "Đã $statusStr nhắc nhở uống nước!", Toast.LENGTH_SHORT).show()
                        },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = EmeraldPrimary,
                            checkedTrackColor = VibrantLightHighlight
                        )
                    )
                }

                Divider(color = LightGrey.copy(alpha = 0.5f), thickness = 1.dp)

                // Gemini AI Companion Mode
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Trợ lý sức khỏe AI (Gemini) 🤖",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.Black
                        )
                        Text(
                            text = "Nhận các đề xuất cá nhân hoá từ mô hình AI khi quét thành phần dinh dưỡng.",
                            fontSize = 10.sp,
                            color = Color.Black.copy(alpha = 0.7f)
                        )
                    }
                    Switch(
                        checked = isAiCompanionEnabled,
                        onCheckedChange = {
                            isAiCompanionEnabled = it
                            val statusStr = if (it) "KÍCH HOẠT" else "VÔ HIỆU HOÁ"
                            Toast.makeText(context, "Trợ lý AI đã được $statusStr!", Toast.LENGTH_SHORT).show()
                        },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = EmeraldPrimary,
                            checkedTrackColor = VibrantLightHighlight
                        )
                    )
                }

                Divider(color = LightGrey.copy(alpha = 0.5f), thickness = 1.dp)

                // Workout alerting
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Nhắc nhở giờ tập rèn luyện ⏱️",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.Black
                        )
                        Text(
                            text = "Báo động trước 10 phút trước mỗi mốc giờ tập được lên lịch.",
                            fontSize = 10.sp,
                            color = Color.Black.copy(alpha = 0.7f)
                        )
                    }
                    Switch(
                        checked = isWorkoutAlertEnabled,
                        onCheckedChange = {
                            isWorkoutAlertEnabled = it
                            val statusStr = if (it) "BẬT" else "TẮT"
                            Toast.makeText(context, "Đã $statusStr thông báo lịch rèn luyện!", Toast.LENGTH_SHORT).show()
                        },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = EmeraldPrimary,
                            checkedTrackColor = VibrantLightHighlight
                        )
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // --- RECOVERY AND MAINTENANCE ACTIONS ---
        Card(
            colors = CardDefaults.cardColors(containerColor = Color(0xFFFCF5F5)),
            border = BorderStroke(1.dp, Color(0xFFF0DCDC)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(14.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "Quản lý dữ liệu hệ thống (Nguy hiểm) ⚠️",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.Red
                )
                Text(
                    text = "Dọn dẹp các mục phân tích lịch sử, trả ứng dụng về trạng thái dồi dào tươi sạch ban đầu.",
                    fontSize = 10.sp,
                    color = Color.Black.copy(alpha = 0.8f)
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Delete Meals button
                OutlinedButton(
                    onClick = { showDeleteMealsDialog = true },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.Red),
                    border = BorderStroke(1.dp, Color.Red.copy(alpha = 0.4f)),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(vertical = 4.dp, horizontal = 12.dp)
                ) {
                    Text("Dọn dẹp nhật ký thực đơn 🍜", fontSize = 11.sp, color = Color.Red, fontWeight = FontWeight.Bold)
                }

                // Delete Foods button
                OutlinedButton(
                    onClick = { showDeleteFoodsDialog = true },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.Red),
                    border = BorderStroke(1.dp, Color.Red.copy(alpha = 0.4f)),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(vertical = 4.dp, horizontal = 12.dp)
                ) {
                    Text("Xoá lịch sử quét thực phẩm 🏷️", fontSize = 11.sp, color = Color.Red, fontWeight = FontWeight.Bold)
                }

                // Delete Workouts button
                OutlinedButton(
                    onClick = { showDeleteWorkoutsDialog = true },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.Red),
                    border = BorderStroke(1.dp, Color.Red.copy(alpha = 0.4f)),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(vertical = 4.dp, horizontal = 12.dp)
                ) {
                    Text("Xoá lịch rèn luyện thể chất 🏃", fontSize = 11.sp, color = Color.Red, fontWeight = FontWeight.Bold)
                }

                Spacer(modifier = Modifier.height(4.dp))
                Divider(color = Color.Red.copy(alpha = 0.15f), thickness = 1.dp)
                Spacer(modifier = Modifier.height(4.dp))

                // Reset all
                Button(
                    onClick = { showResetAllDialog = true },
                    colors = ButtonDefaults.buttonColors(containerColor = Color.Red),
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text("Khôi Phục Toàn Bộ Cài Đặt Gốc 🔄", fontSize = 11.sp, color = Color.White, fontWeight = FontWeight.Bold)
                }
            }
        }

        Spacer(modifier = Modifier.height(40.dp))
    }
}

// --- SYSTEM HEALTH & SCHEDULING HELPER ALGORITHMS ---
data class HealthStatus(
    val bmi: Float,
    val bmiCategory: String,
    val bmr: Int,
    val minDailyExerciseMins: Int,
    val evaluationMessage: String
)

fun calculateHealthStatus(profile: UserProfile?): HealthStatus {
    if (profile == null) {
        return HealthStatus(22.0f, "Bình thường", 1400, 30, "Khai báo hồ sơ cá nhân để nhận gợi ý chỉ số luyện tập dẻo dai khớp thời gian nhất.")
    }
    val w = profile.weight
    val h = profile.height / 100f
    val age = profile.age
    val bmi = if (h > 0) w / (h * h) else 22f
    
    val category = when {
        bmi < 18.5f -> "Thiếu cân (Nhẹ cân)"
        bmi < 24.9f -> "Thể trạng cân đối tốt"
        bmi < 29.9f -> "Thừa cân nhẹ"
        else -> "Béo phì"
    }
    
    val bmr = (10 * w + 6.25f * profile.height - 5 * age + 5).toInt()
    
    var minDailyMins = when (profile.healthGoal) {
        "Giảm cân" -> 35
        "Tăng cân" -> 25
        "Lối sống lành mạnh" -> 30
        else -> 30 // "Giữ cân"
    }
    
    if (bmi > 25f) {
        minDailyMins += ((bmi - 25f) * 2f).toInt()
    } else if (bmi < 18.5f) {
        minDailyMins -= ((18.5f - bmi) * 2f).toInt()
    }
    val calculatedMins = minDailyMins.coerceIn(15, 60)
    
    val evalMsg = when {
        bmi < 18.5f -> "Lời khuyên sức khỏe: Tập luyện vừa sức kết hợp xoa bóp, tập trung giãn cơ dẻo dai lành mạnh để tăng cường trao đổi chất của hệ tiêu hóa dồi dào."
        bmi < 24.9f -> "Lời khuyên sức khỏe: Cơ thể bạn đang rất cân đối! Duy trì tập luyện ít nhất $calculatedMins phút mỗi ngày để tăng sức bền tim mạch & dẻo dai bắp thịt."
        else -> "Lời khuyên sức khỏe: Người thừa cân nên lưu ý tránh các bài nhảy quá nặng gây áp bách lên đầu gối. Khuyên tập $calculatedMins phút nhẹ kết hợp đi bộ nhanh."
    }
    
    return HealthStatus(bmi, category, bmr, calculatedMins, evalMsg)
}

fun autoScheduleWorkouts(
    viewModel: AppViewModel,
    activeDays: Set<String>,
    scope: String,
    healthGoal: String,
    minMins: Int
): Int {
    var count = 0
    val exercisesSelection = when (healthGoal) {
        "Giảm cân" -> listOf(
            Triple("HIIT đốt cháy Calories cấp tốc 🔥", minMins, 270),
            Triple("Cardio ngắn kích tế bào rảnh rỗi ⚡", 15, 140),
            Triple("Chạy bộ cơ bản rèn nhịp thở phổi 🏃‍♂️", minMins, 240)
        )
        "Tăng cân" -> listOf(
            Triple("Squats cơ bản săn chắc hông mông 🏋️‍♂️", minMins, 160),
            Triple("Core Plank vững bền liên sườn 🪵", 20, 135),
            Triple("Super Full Body - Đốt mỡ bứt phá ⚡", minMins, 420)
        )
        else -> listOf(
            Triple("Yoga xoay vai gập cổ vai gáy 🧘", 10, 65),
            Triple("Hít thở cơ hoành xoa dịu stress 🎐", 15, 30),
            Triple("Pilates hồi phục dẻo dai cột sống 🌸", minMins, 290)
        )
    }

    val baseSlots = listOf(
        "06:15 - 06:45",
        "12:15 - 12:35",
        "17:30 - 18:00",
        "21:15 - 21:30"
    )

    when (scope) {
        "1 NGÀY" -> {
            val day = activeDays.firstOrNull() ?: "Thứ 2"
            val slot = baseSlots.random()
            val (exName, duration, cal) = exercisesSelection.random()
            viewModel.scheduleWorkout(exName, duration, cal, "$day • $slot")
            count++
        }
        "1 TUẦN" -> {
            activeDays.forEach { day ->
                val slot = baseSlots.random()
                val (exName, duration, cal) = exercisesSelection.random()
                viewModel.scheduleWorkout(exName, duration, cal, "$day • $slot")
                count++
            }
        }
        "1 THÁNG" -> {
            for (week in 1..4) {
                activeDays.forEach { day ->
                    val slot = baseSlots.random()
                    val (exName, duration, cal) = exercisesSelection.random()
                    viewModel.scheduleWorkout(
                        "T$week • $exName",
                        duration,
                        cal,
                        "$day • $slot"
                    )
                    count++
                }
            }
        }
    }
    return count
}

