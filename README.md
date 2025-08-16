# Chicago Bike Share User Behavior Analysis

**End-to-end business intelligence project analyzing member vs casual user patterns to inform operational strategy**

## Business Problem
Chicago's bike share system needed insights into user behavior differences to optimize operations, improve marketing targeting, and enhance strategic planning. Analyzed 763,000+ trips from July 2025 to identify distinct usage patterns between annual members and casual users.

## Key Findings

### 🎯 **Round Trip Behavior: 3x Usage Difference**
- **Casual users**: 10.2% same-station returns
- **Members**: 3.3% same-station returns  
- **Insight**: Casual users primarily recreational; members transportation-focused

### ⏰ **Asymmetric Commuter Patterns**
- **Members**: Strong afternoon rush (4-6pm peaks) but weak morning commute signals
- **Peak insight**: Members use multimodal transportation - public transit/rideshare inbound, bike home for convenience and exercise
- **Weekend performance**: Members significantly underperform expected 29% weekend usage

### 🚴 **Bike Type Preferences: Not a Differentiator**
- **Both groups prefer electric bikes equally** (Casual: 66%, Members: 64%)
- **Strategic implication**: Bike type not useful for user segmentation or targeted marketing

### 📊 **Data Quality Transparency**
- 75% station ID coverage, 91% coordinate coverage documented
- Analysis designed to work with real-world data limitations
- All findings account for data completeness issues

## Business Impact

**Operational Planning**
- Station placement strategy should account for asymmetric demand patterns
- Bike redistribution needs consider afternoon member concentration vs distributed casual usage

**Marketing Strategy**  
- Target members with commuter convenience messaging
- Position casual offerings around recreation and leisure experiences
- Bike type features equally appealing to both segments

**Revenue Optimization**
- Members represent consistent weekday demand - focus retention efforts here
- Casual users show weekend potential - opportunity for targeted weekend promotions

## Technical Approach

- **SQL-first analysis** with SQLite for data manipulation and statistical analysis
- **Haversine formula implementation** for distance calculations
- **Advanced time-series analysis** using strftime functions for temporal patterns
- **Data quality assessment** with transparent reporting of limitations
- **Statistical validation** including expected vs actual weekend distribution analysis

## Files Structure
```
├── sql/
│   └── tripdata_script.sql          # Complete analysis with methodology
├── docs/
│   └── executive_summary.pdf        # Business-focused presentation
└── visualizations/
    └── dashboard_screenshots/       # Supporting charts and dashboard
```

## Data Source
This analysis uses publicly available Chicago Divvy bike share data from July 2025.
Original dataset available at: [Divvy Data Website](https://divvybikes.com/data)

Due to licensing restrictions, the raw dataset is not included in this repository.

## Skills Demonstrated
- End-to-end business analysis from raw data to strategic recommendations
- Advanced SQL including temporal analysis, geospatial calculations, and data quality assessment  
- Statistical thinking with hypothesis testing and validation
- Business intelligence with focus on actionable insights over technical complexity
- Professional documentation and transparent methodology

---

*This project demonstrates real-world analytical problem-solving: working with imperfect data, extracting meaningful business insights, and communicating findings that drive strategic decisions.*
