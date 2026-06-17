package com.example.ui

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.outlined.CheckCircle
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    viewModel: AppViewModel,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    var selectedTab by remember { mutableStateOf(0) } // 0: Ngày, 1: Tuần, 2: Tháng

    // Data from ViewModel
    val meals by viewModel.mealsState.collectAsStateWithLifecycle()
    val workouts by viewModel.workoutsState.collectAsStateWithLifecycle()
    val profile by viewModel.profileState.collectAsStateWithLifecycle()

    val targetCal = profile?.targetCalories ?: 2000
    val targetPro = profile?.targetProtein ?: 120
    val targetCarb = profile?.targetCarbs ?: 230
    val targetFat = profile?.targetFat ?: 67

    val intakeCal by viewModel.totalCaloriesIntake.collectAsStateWithLifecycle()
    val burnedCal by viewModel.totalCaloriesBurned.collectAsStateWithLifecycle()
    val netCal = intakeCal - burnedCal

    val intakePro by viewModel.totalProteinIntake.collectAsStateWithLifecycle()
    val intakeCarb by viewModel.totalCarbsIntake.collectAsStateWithLifecycle()
    val intakeFat by viewModel.totalFatIntake.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(
                        "Dashboard Phân Tích",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = VibrantTextDark
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Quay lại",
                            tint = VibrantTextDark
                        )
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = VibrantBackground
                )
            )
        },
        containerColor = VibrantBackground
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Elegant day-week-month toggle buttons (Vibrant Palette style)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(Color.White)
                    .border(BorderStroke(1.dp, VibrantBorderMedium), RoundedCornerShape(16.dp))
                    .padding(4.dp),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                listOf("Theo Ngày", "Theo Tuần", "Theo Tháng").forEachIndexed { index, text ->
                    val isSelected = selectedTab == index
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(12.dp))
                            .background(if (isSelected) VibrantPrimary else Color.Transparent)
                            .clickable { selectedTab = index }
                            .padding(vertical = 10.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = text,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (isSelected) Color.White else VibrantTextMedium
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Dynamic Tab Views
            when (selectedTab) {
                0 -> {
                    // --- 1. DAILY DASHBOARD VIEW ---
                    Card(
                        shape = RoundedCornerShape(24.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, VibrantBorderMedium),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                "Tóm tắt dinh dưỡng hôm nay",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                color = VibrantTextDark,
                                modifier = Modifier.fillMaxWidth()
                            )
                            Spacer(modifier = Modifier.height(16.dp))

                            // Giant interactive gauge ring
                            Box(
                                contentAlignment = Alignment.Center,
                                modifier = Modifier.size(150.dp)
                            ) {
                                val percentage = (netCal.toFloat() / targetCal.toFloat()).coerceIn(0f, 1f)
                                CircularProgressIndicator(
                                    progress = { percentage },
                                    modifier = Modifier.fillMaxSize(),
                                    color = VibrantPrimary,
                                    strokeWidth = 12.dp,
                                    trackColor = VibrantLightHighlight,
                                    strokeCap = StrokeCap.Round,
                                )
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(
                                        text = "$netCal",
                                        fontSize = 32.sp,
                                        fontWeight = FontWeight.Black,
                                        color = VibrantTextDark
                                    )
                                    Text(
                                        text = "Kcal Tịnh",
                                        fontSize = 10.sp,
                                        color = VibrantTextLight,
                                        fontWeight = FontWeight.SemiBold
                                    )
                                    Text(
                                        text = "Mục tiêu: $targetCal",
                                        fontSize = 11.sp,
                                        color = VibrantTextMedium,
                                        fontWeight = FontWeight.Bold,
                                        modifier = Modifier.padding(top = 4.dp)
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.height(20.dp))

                            // Highlight macro stats
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                MacroRowItem(label = "ĐẠM (g)", current = intakePro, target = targetPro, color = VibrantPrimary, modifier = Modifier.weight(1f))
                                MacroRowItem(label = "CARBS (g)", current = intakeCarb, target = targetCarb, color = VibrantSunburst, modifier = Modifier.weight(1f))
                                MacroRowItem(label = "BÉO (g)", current = intakeFat, target = targetFat, color = VibrantAlertCoral, modifier = Modifier.weight(1f))
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Meal structure list
                    Card(
                        shape = RoundedCornerShape(24.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, VibrantBorderMedium),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text(
                                "Phân Bổ Calo Bữa Ăn",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                color = VibrantTextDark,
                                modifier = Modifier.padding(bottom = 12.dp)
                            )

                            val mealBreakdown = listOf("Sáng", "Trưa", "Tối", "Nhẹ").map { type ->
                                type to meals.filter { it.mealType == type }.sumOf { it.calories }
                            }

                            mealBreakdown.forEach { (type, calories) ->
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(vertical = 8.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Box(
                                            modifier = Modifier
                                                .size(36.dp)
                                                .clip(CircleShape)
                                                .background(VibrantLightHighlight),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Icon(
                                                imageVector = Icons.Filled.Check,
                                                contentDescription = null,
                                                tint = VibrantPrimary,
                                                modifier = Modifier.size(16.dp)
                                            )
                                        }
                                        Spacer(modifier = Modifier.width(12.dp))
                                        Column {
                                            Text("Bữa $type", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                                            val count = meals.filter { it.mealType == type }.size
                                            Text("$count món ăn đã log", fontSize = 11.sp, color = VibrantTextLight)
                                        }
                                    }
                                    
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Text(
                                            text = "$calories",
                                            fontSize = 15.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = VibrantTextDark
                                        )
                                        Text(" Kcal", fontSize = 11.sp, color = VibrantTextLight)
                                    }
                                }
                                Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(VibrantBorderMedium.copy(alpha = 0.5f)))
                            }
                        }
                    }
                }

                1 -> {
                    // --- 2. WEEKLY DASHBOARD VIEW (Custom Canvas Bar Chart) ---
                    Card(
                        shape = RoundedCornerShape(24.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, VibrantBorderMedium),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(20.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column {
                                    Text(
                                        "Lượng Calo Tiêu Thụ Trong Tuần",
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = VibrantTextDark
                                    )
                                    Text(
                                        "Biểu đồ cột so sánh Nạp 🟢 vs Đốt 🔴",
                                        fontSize = 11.sp,
                                        color = VibrantTextLight
                                    )
                                }
                                Icon(
                                    imageVector = Icons.Filled.Star,
                                    contentDescription = null,
                                    tint = VibrantPrimary,
                                    modifier = Modifier.size(24.dp)
                                )
                            }

                            Spacer(modifier = Modifier.height(24.dp))

                            // Draw Weekly graph inside premium Canvas
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(180.dp)
                            ) {
                                // Dynamic simulated week days (adding current day's entries dynamically)
                                val currentDayOfWeekIdx = 1 // Tuesday is highlighted
                                val weekDays = listOf(
                                    WeekdayData("T2", 1750, 200),
                                    WeekdayData("T3", intakeCal, burnedCal), // Today live values!
                                    WeekdayData("T4", 1900, 300),
                                    WeekdayData("T5", 1600, 150),
                                    WeekdayData("T6", 2100, 450),
                                    WeekdayData("T7", 1850, 200),
                                    WeekdayData("CN", 2200, 100)
                                )

                                Canvas(modifier = Modifier.fillMaxSize()) {
                                    val totalWidth = size.width
                                    val totalHeight = size.height
                                    val barWidth = 14.dp.toPx()
                                    val spacing = (totalWidth - (barWidth * 2 * 7)) / 8
                                    val maxCalValue = 2800f

                                    // Y gridlines
                                    for (i in 1..3) {
                                        val y = totalHeight - (totalHeight * (i.toFloat() / 3.5f))
                                        drawLine(
                                            color = VibrantBorderMedium.copy(alpha = 0.5f),
                                            start = Offset(0f, y),
                                            end = Offset(totalWidth, y),
                                            strokeWidth = 1.dp.toPx()
                                        )
                                    }

                                    weekDays.forEachIndexed { idx, data ->
                                        // X center coordinate for this daytime capsule group 
                                        val xCenter = spacing + idx * (barWidth * 2 + spacing) + barWidth

                                        // 1. Draw Intake Bar (Green/Sage)
                                        val intakeHeightRatio = (data.intake.toFloat() / maxCalValue).coerceIn(0.01f, 1f)
                                        val intakeBarHeight = (totalHeight - 30.dp.toPx()) * intakeHeightRatio
                                        val intakeBottomY = totalHeight - 20.dp.toPx()
                                        val intakeTopY = intakeBottomY - intakeBarHeight

                                        drawRoundRect(
                                            color = if (idx == currentDayOfWeekIdx) VibrantPrimary else VibrantPrimary.copy(alpha = 0.5f),
                                            topLeft = Offset(xCenter - barWidth - 2.dp.toPx(), intakeTopY),
                                            size = Size(barWidth, intakeBarHeight.coerceAtLeast(1f)),
                                            cornerRadius = CornerRadius(12f, 12f)
                                        )

                                        // 2. Draw Burned Bar (Alert Coral)
                                        val burnedHeightRatio = (data.burned.toFloat() / maxCalValue).coerceIn(0.01f, 1f)
                                        val burnedBarHeight = (totalHeight - 30.dp.toPx()) * burnedHeightRatio
                                        val burnedTopY = intakeBottomY - burnedBarHeight

                                        drawRoundRect(
                                            color = if (idx == currentDayOfWeekIdx) VibrantAlertCoral else VibrantAlertCoral.copy(alpha = 0.5f),
                                            topLeft = Offset(xCenter + 2.dp.toPx(), burnedTopY),
                                            size = Size(barWidth, burnedBarHeight.coerceAtLeast(1f)),
                                            cornerRadius = CornerRadius(12f, 12f)
                                        )
                                    }
                                }

                                // Overlay text labels positioned at the bottom coordinates
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .align(Alignment.BottomCenter)
                                        .padding(horizontal = 4.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    listOf("T2", "T3", "T4", "T5", "T6", "T7", "CN").forEachIndexed { idx, day ->
                                        val isToday = idx == currentDayOfWeekIdx
                                        Text(
                                            text = day,
                                            fontSize = 11.sp,
                                            fontWeight = if (isToday) FontWeight.Black else FontWeight.Medium,
                                            color = if (isToday) VibrantPrimary else VibrantTextLight,
                                            textAlign = TextAlign.Center,
                                            modifier = Modifier.width(32.dp)
                                        )
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.height(20.dp))

                            // Brief health stats cards 
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                Card(
                                    colors = CardDefaults.cardColors(containerColor = VibrantLightHighlight),
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Column(modifier = Modifier.padding(12.dp)) {
                                        Text("Trung bình tiêu thụ", fontSize = 10.sp, color = VibrantTextLight, fontWeight = FontWeight.SemiBold)
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text("1,885 kcal/ngày", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                                    }
                                }
                                Card(
                                    colors = CardDefaults.cardColors(containerColor = Color(0xFFFFECE6)),
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Column(modifier = Modifier.padding(12.dp)) {
                                        Text("Tổng năng lượng đốt", fontSize = 10.sp, color = VibrantTextLight, fontWeight = FontWeight.SemiBold)
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Text("1,650 kcal/tuần", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = VibrantAlertCoral)
                                    }
                                }
                            }
                        }
                    }
                }

                2 -> {
                    // --- 3. MONTHLY DASHBOARD VIEW (Spline Line Area Chart) ---
                    Card(
                        shape = RoundedCornerShape(24.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, VibrantBorderMedium),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.padding(20.dp)) {
                            Text(
                                "Xu Hướng Cân Nặng & Calo Tịnh 30 Ngày",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                color = VibrantTextDark
                            )
                            Text(
                                "Đồ thị lượn dốc thể hiện tính đều đặn trong giữ mục tiêu",
                                fontSize = 11.sp,
                                color = VibrantTextLight,
                                modifier = Modifier.padding(bottom = 16.dp)
                            )

                            // Spline Canvas Line Curve
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(160.dp)
                            ) {
                                val calMonthlyHistory = listOf(2100, 1950, 1780, 1850, intakeCal, 1900, 1750) // Week history points
                                Canvas(modifier = Modifier.fillMaxSize()) {
                                    val w = size.width
                                    val h = size.height
                                    val stepX = w / 6f
                                    val maxVal = 2605f

                                    // Guide coordinate calculations 
                                    val path = Path()
                                    val fillPath = Path()

                                    calMonthlyHistory.forEachIndexed { i, valPoint ->
                                        val x = i * stepX
                                        val yRatio = (valPoint.toFloat() / maxVal).coerceIn(0.1f, 0.9f)
                                        val y = h - (h * yRatio)

                                        if (i == 0) {
                                            path.moveTo(x, y)
                                            fillPath.moveTo(x, h)
                                            fillPath.lineTo(x, y)
                                        } else {
                                            // Simple cubic/quadratic spline lookalike
                                            val prevX = (i - 1) * stepX
                                            val prevYRatio = (calMonthlyHistory[i - 1].toFloat() / maxVal).coerceIn(0.1f, 0.9f)
                                            val prevY = h - (h * prevYRatio)
                                            
                                            path.cubicTo(
                                                (prevX + x) / 2, prevY,
                                                (prevX + x) / 2, y,
                                                x, y
                                            )
                                            fillPath.cubicTo(
                                                (prevX + x) / 2, prevY,
                                                (prevX + x) / 2, y,
                                                x, y
                                            )
                                        }
                                        
                                        if (i == calMonthlyHistory.lastIndex) {
                                            fillPath.lineTo(x, h)
                                            fillPath.close()
                                        }
                                    }

                                    // Draw background visual area gradient
                                    drawPath(
                                        path = fillPath,
                                        brush = Brush.verticalGradient(
                                            colors = listOf(VibrantLightHighlight, Color.Unspecified),
                                            startY = 10f,
                                            endY = h
                                        )
                                    )

                                    // Draw primary line
                                    drawPath(
                                        path = path,
                                        color = VibrantPrimary,
                                        style = Stroke(width = 3.dp.toPx())
                                    )

                                    // Draw dynamic dotted target line 
                                    val targetLineY = h - (h * (targetCal.toFloat() / maxVal))
                                    drawLine(
                                        color = VibrantAlertCoral,
                                        start = Offset(0f, targetLineY),
                                        end = Offset(w, targetLineY),
                                        strokeWidth = 1.dp.toPx(),
                                        pathEffect = androidx.compose.ui.graphics.PathEffect.dashPathEffect(
                                            floatArrayOf(10f, 10f), 0f
                                        )
                                    )
                                }
                            }

                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(top = 8.dp),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                listOf("Tuần 1", "Tuần 2", "Tuần 3", "Tuần 4", "Hôm nay").forEach { label ->
                                    Text(label, fontSize = 10.sp, fontWeight = FontWeight.Bold, color = VibrantTextLight)
                                }
                            }

                            Spacer(modifier = Modifier.height(18.dp))

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Filled.Star,
                                    contentDescription = null,
                                    tint = VibrantVolt,
                                    modifier = Modifier
                                        .size(36.dp)
                                        .background(VibrantSecondary, RoundedCornerShape(8.dp))
                                        .padding(6.dp)
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                Column {
                                    Text("Kết quả tháng 6/2026", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = VibrantTextDark)
                                    Text("Cân nặng giảm từ 62kg -> 60kg theo kế hoạch đề ra.", fontSize = 11.sp, color = VibrantTextLight)
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Global wellness card advice
            Card(
                colors = CardDefaults.cardColors(containerColor = VibrantSecondary),
                shape = RoundedCornerShape(24.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(18.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Outlined.CheckCircle,
                        contentDescription = null,
                        tint = VibrantVolt,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text(
                            text = "Lời khuyên vàng hôm nay từ HealTrack 🌱",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = VibrantVolt
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "Duy trì uống đủ 2 lít nước và tập các bài tập rảnh rỗi trên 20 phút mỗi ngày sẽ tăng tỷ lệ tiêu thụ năng lượng cơ bản cơ thể lên 12%!",
                            fontSize = 11.sp,
                            color = Color.White.copy(alpha = 0.85f),
                            lineHeight = 16.sp
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun MacroRowItem(
    label: String,
    current: Int,
    target: Int,
    color: Color,
    modifier: Modifier = Modifier
) {
    val ratio = if (target > 0) (current.toFloat() / target.toFloat()).coerceIn(0f, 1f) else 0f
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(VibrantBackground)
            .border(BorderStroke(1.dp, VibrantBorderMedium), RoundedCornerShape(16.dp))
            .padding(10.dp)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = label,
                fontSize = 9.sp,
                fontWeight = FontWeight.Bold,
                color = VibrantTextLight
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "$current / $target",
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = VibrantTextDark
            )
            Spacer(modifier = Modifier.height(6.dp))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(VibrantBorderMedium)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .fillMaxWidth(ratio)
                        .background(color)
                )
            }
        }
    }
}

// Simple Weekday helper data 
data class WeekdayData(
    val day: String,
    val intake: Int,
    val burned: Int
)
