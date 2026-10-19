/*
DB_DIENDANDOCSACH - DATABASE DAY DU CHO UNG DUNG SACH MOI DA DEN
Chay toan bo Database/DB_DienDanDocSach.sql trong SSMS hoac sqlcmd.
SQL Server 2012+; ten database SachMoiDaDen khop appsettings.json.

- 16 bang, 3 view, 7 procedure, 3 trigger, 1 table type; day du khoa va index.
- Giu toan bo du lieu dbsach.sql: 8 tai khoan, 48 sach, 288 chuong,
  432 metadata tep, 156 binh luan, 15 bao cao va cac du lieu lien quan.
- Metadata cua 03_BoSungNoiDungChuong.sql da co du, khong nap trung.
- Da tich hop quy tac cua 04_CongLuotDocMoiLan.sql: moi lan tai khoan
  dang nhap doc/mo lai/chuyen chuong deu cong 1 luot va cap nhat lich su.
  Khach van chong dem lap 30 phut; xem truoc/lay tung tep khong cong luot.
- Bo sung 3 trigger tu 01_SachMoiDaDenV3.sql de giu kiem tra nghiep vu.
- SQL dung thu muc du lieu mac dinh; khong ep tuy chon SQL Server 2022.
- Chi tao va nap tren database moi/trong; dung neu da co doi tuong dbo.
  Khong xoa hoac ghi de database dang dung.
- Tep TXT/MD/anh/PDF van nam trong App_Data/Chapters; SQL luu metadata.
- Cuoi file co 15 ca kiem tra tuy chon: doi @ChayKiemTra thanh 1 de chay;
  fixture cua cac ca kiem tra duoc rollback, khong giu du lieu test.
*/
USE [master];
GO
SET NOCOUNT ON;
IF DB_ID(N'SachMoiDaDen') IS NULL
    EXEC(N'CREATE DATABASE [SachMoiDaDen];');
GO
USE [SachMoiDaDen];
GO
-- NOEXEC ngan cac batch tiep theo chay neu database khong phu hop.
-- SET NOEXEC OFF o cuoi file khoi phuc trang thai cua cua so truy van.
IF DB_NAME() <> N'SachMoiDaDen'
   OR EXISTS (SELECT 1 FROM sys.objects
              WHERE schema_id = SCHEMA_ID(N'dbo') AND is_ms_shipped = 0)
BEGIN
    RAISERROR(N'Database dich da co doi tuong, hoac chua chuyen duoc sang SachMoiDaDen. Dung nap de giu nguyen du lieu hien tai.', 16, 1);
    SET NOEXEC ON;
END;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
/****** Object:  UserDefinedTableType [dbo].[DanhSachTepNoiDung]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE TYPE [dbo].[DanhSachTepNoiDung] AS TABLE(
	[ThuTu] [int] NOT NULL,
	[DuongDanTep] [varchar](450) NOT NULL,
	[KieuTep] [varchar](30) NOT NULL,
	[TenTepGoc] [nvarchar](255) NOT NULL,
	[DungLuong] [bigint] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[ThuTu] ASC
)WITH (IGNORE_DUP_KEY = OFF),
	UNIQUE NONCLUSTERED 
(
	[DuongDanTep] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  Table [dbo].[TheLoai]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TheLoai](
	[MaTheLoai] [int] IDENTITY(1,1) NOT NULL,
	[TenTheLoai] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_TheLoai] PRIMARY KEY CLUSTERED 
(
	[MaTheLoai] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sach]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sach](
	[MaSach] [int] IDENTITY(1,1) NOT NULL,
	[TenSach] [nvarchar](160) NOT NULL,
	[TacGia] [nvarchar](100) NOT NULL,
	[GioiThieu] [nvarchar](3000) NOT NULL,
	[LoaiTruyen] [tinyint] NOT NULL,
	[TrangThaiSangTac] [tinyint] NOT NULL,
	[MaNguoiDang] [int] NOT NULL,
	[ChoDuyet] [bit] NOT NULL,
	[BiAn] [bit] NOT NULL,
	[LuotDoc] [bigint] NOT NULL,
	[NgayTao] [datetime2](3) NOT NULL,
	[NgayCapNhat] [datetime2](3) NOT NULL,
	[HinhAnhBia] [varbinary](max) NULL,
	[KieuAnhBia] [varchar](20) NULL,
 CONSTRAINT [PK_Sach] PRIMARY KEY CLUSTERED 
(
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SachTheLoai]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SachTheLoai](
	[MaSach] [int] NOT NULL,
	[MaTheLoai] [int] NOT NULL,
	[ThuTu] [smallint] NOT NULL,
 CONSTRAINT [PK_SachTheLoai] PRIMARY KEY CLUSTERED 
(
	[MaSach] ASC,
	[MaTheLoai] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Chuong]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Chuong](
	[MaChuong] [int] IDENTITY(1,1) NOT NULL,
	[MaSach] [int] NOT NULL,
	[SoChuong] [int] NOT NULL,
	[TieuDe] [nvarchar](160) NOT NULL,
	[NgayTao] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Chuong] PRIMARY KEY CLUSTERED 
(
	[MaChuong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DanhGia]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DanhGia](
	[MaTaiKhoan] [int] NOT NULL,
	[MaSach] [int] NOT NULL,
	[SoSao] [tinyint] NOT NULL,
	[NgayDanhGia] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_DanhGia] PRIMARY KEY CLUSTERED 
(
	[MaTaiKhoan] ASC,
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_SachCongKhai]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_SachCongKhai] AS
SELECT s.MaSach,s.TenSach,s.TacGia,s.GioiThieu,s.LoaiTruyen,s.TrangThaiSangTac,
       s.MaNguoiDang,s.LuotDoc,s.NgayTao,s.NgayCapNhat,
       STUFF((SELECT N' · '+t.TenTheLoai FROM dbo.SachTheLoai st
           JOIN dbo.TheLoai t ON t.MaTheLoai=st.MaTheLoai WHERE st.MaSach=s.MaSach
           ORDER BY st.ThuTu FOR XML PATH(''),TYPE).value('.','nvarchar(max)'),1,3,N'') AS TenTheLoai,
       (SELECT COUNT(*) FROM dbo.Chuong c WHERE c.MaSach=s.MaSach) AS SoChuong,
       (SELECT COUNT(*) FROM dbo.DanhGia d WHERE d.MaSach=s.MaSach) AS SoDanhGia,
       (SELECT AVG(CONVERT(decimal(10,6),d.SoSao)) FROM dbo.DanhGia d WHERE d.MaSach=s.MaSach) AS DiemTrungBinh
FROM dbo.Sach s WHERE s.ChoDuyet=0 AND s.BiAn=0;
GO
/****** Object:  Table [dbo].[BaiThaoLuan]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BaiThaoLuan](
	[MaBaiThaoLuan] [int] IDENTITY(1,1) NOT NULL,
	[MaTaiKhoan] [int] NOT NULL,
	[TieuDe] [nvarchar](160) NOT NULL,
	[NoiDung] [nvarchar](max) NOT NULL,
	[BiAn] [bit] NOT NULL,
	[NgayTao] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_BaiThaoLuan] PRIMARY KEY CLUSTERED 
(
	[MaBaiThaoLuan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaiKhoan]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaiKhoan](
	[MaTaiKhoan] [int] IDENTITY(1,1) NOT NULL,
	[TenHienThi] [nvarchar](80) NOT NULL,
	[Email] [nvarchar](200) NOT NULL,
	[MatKhauHash] [nvarchar](512) NOT NULL,
	[MaVaiTro] [varchar](20) NOT NULL,
	[BiKhoa] [bit] NOT NULL,
	[DauBaoMat] [uniqueidentifier] NOT NULL,
	[NgayTao] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_TaiKhoan] PRIMARY KEY CLUSTERED 
(
	[MaTaiKhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_BaiThaoLuanCongKhai]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_BaiThaoLuanCongKhai] AS
SELECT p.*,u.TenHienThi FROM dbo.BaiThaoLuan p JOIN dbo.TaiKhoan u ON u.MaTaiKhoan=p.MaTaiKhoan
WHERE p.BiAn=0;
GO
/****** Object:  Table [dbo].[BinhLuan]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BinhLuan](
	[MaBinhLuan] [int] IDENTITY(1,1) NOT NULL,
	[MaSach] [int] NULL,
	[MaChuong] [int] NULL,
	[MaBaiThaoLuan] [int] NULL,
	[MaBinhLuanCha] [int] NULL,
	[MaTaiKhoan] [int] NOT NULL,
	[NoiDung] [nvarchar](2000) NOT NULL,
	[BiAn] [bit] NOT NULL,
	[NgayTao] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_BinhLuan] PRIMARY KEY CLUSTERED 
(
	[MaBinhLuan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_BinhLuanCongKhai]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_BinhLuanCongKhai] AS
WITH Cay AS (
    SELECT b.MaBinhLuan,b.MaSach,b.MaChuong,b.MaBaiThaoLuan,b.MaBinhLuanCha,b.MaTaiKhoan,b.NoiDung,b.BiAn,b.NgayTao,
        b.MaBinhLuan AS MaGoc
    FROM dbo.BinhLuan b WHERE b.MaBinhLuanCha IS NULL AND b.BiAn=0
      AND ((b.MaSach IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Sach s WHERE s.MaSach=b.MaSach AND s.ChoDuyet=0 AND s.BiAn=0))
        OR (b.MaChuong IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Chuong c JOIN dbo.Sach s ON s.MaSach=c.MaSach
            WHERE c.MaChuong=b.MaChuong AND s.ChoDuyet=0 AND s.BiAn=0))
        OR (b.MaBaiThaoLuan IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.vw_BaiThaoLuanCongKhai p WHERE p.MaBaiThaoLuan=b.MaBaiThaoLuan)))
    UNION ALL
    SELECT b.MaBinhLuan,b.MaSach,b.MaChuong,b.MaBaiThaoLuan,b.MaBinhLuanCha,b.MaTaiKhoan,b.NoiDung,b.BiAn,b.NgayTao,c.MaGoc
    FROM dbo.BinhLuan b JOIN Cay c ON c.MaBinhLuan=b.MaBinhLuanCha WHERE b.BiAn=0
)
SELECT c.*,u.TenHienThi FROM Cay c JOIN dbo.TaiKhoan u ON u.MaTaiKhoan=c.MaTaiKhoan;
GO
/****** Object:  Table [dbo].[BaiThaoLuanTag]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BaiThaoLuanTag](
	[MaBaiThaoLuan] [int] NOT NULL,
	[MaTag] [int] NOT NULL,
	[ThuTu] [tinyint] NOT NULL,
 CONSTRAINT [PK_BaiThaoLuanTag] PRIMARY KEY CLUSTERED 
(
	[MaBaiThaoLuan] ASC,
	[MaTag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BaoCao]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BaoCao](
	[MaBaoCao] [int] IDENTITY(1,1) NOT NULL,
	[MaNguoiBaoCao] [int] NOT NULL,
	[MaSach] [int] NULL,
	[MaBaiThaoLuan] [int] NULL,
	[MaBinhLuan] [int] NULL,
	[NoiDungBiBaoCao] [nvarchar](2000) NOT NULL,
	[LyDo] [nvarchar](1000) NOT NULL,
	[NgayBaoCao] [datetime2](3) NOT NULL,
	[DaXuLy] [bit] NOT NULL,
	[MaNguoiXuLy] [int] NULL,
	[KetQuaXuLy] [nvarchar](1000) NULL,
	[NgayXuLy] [datetime2](3) NULL,
 CONSTRAINT [PK_BaoCao] PRIMARY KEY CLUSTERED 
(
	[MaBaoCao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LichSuDoc]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LichSuDoc](
	[MaTaiKhoan] [int] NOT NULL,
	[MaSach] [int] NOT NULL,
	[MaChuong] [int] NOT NULL,
	[LanDocCuoi] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_LichSuDoc] PRIMARY KEY CLUSTERED 
(
	[MaTaiKhoan] ASC,
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LuotDocSach]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LuotDocSach](
	[MaLuotDoc] [bigint] IDENTITY(1,1) NOT NULL,
	[MaSach] [int] NOT NULL,
	[MaTaiKhoan] [int] NULL,
	[MaKhach] [uniqueidentifier] NULL,
	[ThoiDiem] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_LuotDocSach] PRIMARY KEY CLUSTERED 
(
	[MaLuotDoc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NoiDungChuong]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NoiDungChuong](
	[MaNoiDung] [int] IDENTITY(1,1) NOT NULL,
	[MaChuong] [int] NOT NULL,
	[ThuTu] [int] NOT NULL,
	[DuongDanTep] [varchar](450) NOT NULL,
	[KieuTep] [varchar](30) NOT NULL,
	[TenTepGoc] [nvarchar](255) NOT NULL,
	[DungLuong] [bigint] NOT NULL,
 CONSTRAINT [PK_NoiDungChuong] PRIMARY KEY CLUSTERED 
(
	[MaNoiDung] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tag]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tag](
	[MaTag] [int] IDENTITY(1,1) NOT NULL,
	[TenTag] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Tag] PRIMARY KEY CLUSTERED 
(
	[MaTag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TuSach]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TuSach](
	[MaTaiKhoan] [int] NOT NULL,
	[MaSach] [int] NOT NULL,
	[NgayLuu] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_TuSach] PRIMARY KEY CLUSTERED 
(
	[MaTaiKhoan] ASC,
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VaiTro]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VaiTro](
	[MaVaiTro] [varchar](20) NOT NULL,
	[TenVaiTro] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_VaiTro] PRIMARY KEY CLUSTERED 
(
	[MaVaiTro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[BaiThaoLuan] ON 

INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (1, 3, N'Bạn thích đọc truyện vào lúc nào? · chủ đề 1', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (2, 4, N'Gợi ý truyện kỳ ảo cho người mới · chủ đề 2', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T13:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (3, 5, N'Một khung tranh kể được bao nhiêu điều? · chủ đề 3', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T12:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (4, 6, N'Chia sẻ cách ghi chú khi đọc · chủ đề 4', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T11:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (5, 7, N'Thảo luận về kết thúc mở · chủ đề 5', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T10:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (6, 3, N'Luyện viết một đoạn mở đầu · chủ đề 6', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T09:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (7, 4, N'Bạn thích đọc truyện vào lúc nào? · chủ đề 7', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T08:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (8, 5, N'Gợi ý truyện kỳ ảo cho người mới · chủ đề 8', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T07:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (9, 6, N'Một khung tranh kể được bao nhiêu điều? · chủ đề 9', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T06:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (10, 7, N'Chia sẻ cách ghi chú khi đọc · chủ đề 10', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T05:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (11, 3, N'Thảo luận về kết thúc mở · chủ đề 11', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T04:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (12, 4, N'Luyện viết một đoạn mở đầu · chủ đề 12', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T03:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (13, 5, N'Bạn thích đọc truyện vào lúc nào? · chủ đề 13', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T02:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (14, 6, N'Gợi ý truyện kỳ ảo cho người mới · chủ đề 14', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T01:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (15, 7, N'Một khung tranh kể được bao nhiêu điều? · chủ đề 15', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-07T00:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (16, 3, N'Chia sẻ cách ghi chú khi đọc · chủ đề 16', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-06T23:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (17, 4, N'Thảo luận về kết thúc mở · chủ đề 17', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 0, CAST(N'2026-10-06T22:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaiThaoLuan] ([MaBaiThaoLuan], [MaTaiKhoan], [TieuDe], [NoiDung], [BiAn], [NgayTao]) VALUES (18, 5, N'Luyện viết một đoạn mở đầu · chủ đề 18', N'[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', 1, CAST(N'2026-10-06T21:08:15.5400000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[BaiThaoLuan] OFF
GO
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (1, 1, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (1, 2, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (2, 2, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (2, 3, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (3, 3, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (3, 4, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (4, 4, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (4, 5, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (5, 5, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (5, 6, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (6, 6, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (6, 1, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (7, 1, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (7, 2, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (8, 2, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (8, 3, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (9, 3, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (9, 4, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (10, 4, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (10, 5, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (11, 5, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (11, 6, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (12, 6, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (12, 1, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (13, 1, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (13, 2, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (14, 2, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (14, 3, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (15, 3, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (15, 4, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (16, 4, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (16, 5, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (17, 5, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (17, 6, 2)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (18, 6, 1)
INSERT [dbo].[BaiThaoLuanTag] ([MaBaiThaoLuan], [MaTag], [ThuTu]) VALUES (18, 1, 2)
GO
SET IDENTITY_INSERT [dbo].[BaoCao] ON 

INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (1, 5, 1, NULL, NULL, N'Ngọn đèn bên bến sương', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 1, 2, N'[Kết quả mẫu] Đã kiểm tra, giữ nguyên nội dung.', CAST(N'2026-10-10T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (2, 6, 2, NULL, NULL, N'Cánh cửa dưới gốc đa', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (3, 7, 3, NULL, NULL, N'Bản đồ của người giữ gió', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 1, 2, N'[Kết quả mẫu] Đã kiểm tra, giữ nguyên nội dung.', CAST(N'2026-10-10T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (4, 5, 4, NULL, NULL, N'Những lá thư từ đảo xa', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (5, 6, NULL, 1, NULL, N'Bạn thích đọc truyện vào lúc nào? · chủ đề 1
[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 1, 2, N'[Kết quả mẫu] Đã kiểm tra, giữ nguyên nội dung.', CAST(N'2026-10-10T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (6, 7, NULL, 2, NULL, N'Gợi ý truyện kỳ ảo cho người mới · chủ đề 2
[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (7, 5, NULL, 3, NULL, N'Một khung tranh kể được bao nhiêu điều? · chủ đề 3
[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 1, 2, N'[Kết quả mẫu] Đã kiểm tra, giữ nguyên nội dung.', CAST(N'2026-10-10T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (8, 6, NULL, 4, NULL, N'Chia sẻ cách ghi chú khi đọc · chủ đề 4
[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (9, 7, NULL, NULL, 1, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 1, 2, N'[Kết quả mẫu] Đã kiểm tra, giữ nguyên nội dung.', CAST(N'2026-10-10T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (10, 5, NULL, NULL, 6, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (11, 6, NULL, NULL, 11, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 1, 2, N'[Kết quả mẫu] Đã kiểm tra, giữ nguyên nội dung.', CAST(N'2026-10-10T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (12, 7, NULL, NULL, 16, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', N'[Báo cáo mẫu] Đề nghị kiểm tra nội dung để thử hàng đợi kiểm duyệt.', CAST(N'2026-10-09T14:08:15.5400000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (13, 1, NULL, 1, NULL, N'Bạn thích đọc truyện vào lúc nào? · chủ đề 1
[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', N'gay', CAST(N'2026-10-14T06:33:13.1720000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (14, 1, NULL, 1, NULL, N'Bạn thích đọc truyện vào lúc nào? · chủ đề 1
[Bài thảo luận mẫu] Mình muốn nghe trải nghiệm của mọi người. Hãy chia sẻ một ví dụ, lý do bạn chọn cách đọc đó và một điều bạn muốn thử trong tuần tới. Bài này độc lập với sách, dùng để thử tag, gợi ý, bình luận và báo cáo.', N'gay', CAST(N'2026-10-14T06:55:44.9980000' AS DateTime2), 0, NULL, NULL, NULL)
INSERT [dbo].[BaoCao] ([MaBaoCao], [MaNguoiBaoCao], [MaSach], [MaBaiThaoLuan], [MaBinhLuan], [NoiDungBiBaoCao], [LyDo], [NgayBaoCao], [DaXuLy], [MaNguoiXuLy], [KetQuaXuLy], [NgayXuLy]) VALUES (15, 1, 1, NULL, NULL, N'Ngọn đèn bên bến sương', N'gayhttps://localhost:7034/Story/Read/1', CAST(N'2026-10-14T06:55:52.4730000' AS DateTime2), 0, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[BaoCao] OFF
GO
SET IDENTITY_INSERT [dbo].[BinhLuan] ON 

INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (1, 1, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:25.0650000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (2, 1, NULL, NULL, 1, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:25.2650000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (3, NULL, 1, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:25.3320000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (4, 1, NULL, NULL, NULL, 6, N'Bình luận mẫu đã bị ẩn bởi kiểm duyệt viên.', 1, CAST(N'2026-10-08T14:08:25.4070000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (5, 1, NULL, NULL, 4, 7, N'Phản hồi này phải bị ẩn theo bình luận cha.', 0, CAST(N'2026-10-08T14:08:25.4930000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (6, 2, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:25.5330000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (7, 2, NULL, NULL, 6, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:25.5930000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (8, NULL, 7, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:25.9530000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (9, 2, NULL, NULL, NULL, 6, N'Bình luận mẫu đã bị ẩn bởi kiểm duyệt viên.', 1, CAST(N'2026-10-08T14:08:26.0710000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (10, 2, NULL, NULL, 9, 7, N'Phản hồi này phải bị ẩn theo bình luận cha.', 0, CAST(N'2026-10-08T14:08:26.1120000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (11, 3, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:26.2840000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (12, 3, NULL, NULL, 11, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:26.3270000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (13, NULL, 13, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:26.4270000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (14, 3, NULL, NULL, NULL, 6, N'Bình luận mẫu đã bị ẩn bởi kiểm duyệt viên.', 1, CAST(N'2026-10-08T14:08:26.4910000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (15, 3, NULL, NULL, 14, 7, N'Phản hồi này phải bị ẩn theo bình luận cha.', 0, CAST(N'2026-10-08T14:08:26.6490000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (16, 4, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:26.6880000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (17, 4, NULL, NULL, 16, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:26.7600000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (18, NULL, 19, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:26.9710000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (19, 4, NULL, NULL, NULL, 6, N'Bình luận mẫu đã bị ẩn bởi kiểm duyệt viên.', 1, CAST(N'2026-10-08T14:08:27.0050000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (20, 4, NULL, NULL, 19, 7, N'Phản hồi này phải bị ẩn theo bình luận cha.', 0, CAST(N'2026-10-08T14:08:27.0360000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (21, 5, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:27.0790000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (22, 5, NULL, NULL, 21, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:27.1380000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (23, NULL, 25, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:27.1910000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (24, 5, NULL, NULL, NULL, 6, N'Bình luận mẫu đã bị ẩn bởi kiểm duyệt viên.', 1, CAST(N'2026-10-08T14:08:27.2110000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (25, 5, NULL, NULL, 24, 7, N'Phản hồi này phải bị ẩn theo bình luận cha.', 0, CAST(N'2026-10-08T14:08:27.2270000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (26, 6, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:27.2580000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (27, 6, NULL, NULL, 26, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:27.3400000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (28, NULL, 31, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:27.4030000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (29, 6, NULL, NULL, NULL, 6, N'Bình luận mẫu đã bị ẩn bởi kiểm duyệt viên.', 1, CAST(N'2026-10-08T14:08:27.4660000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (30, 6, NULL, NULL, 29, 7, N'Phản hồi này phải bị ẩn theo bình luận cha.', 0, CAST(N'2026-10-08T14:08:27.5390000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (31, 7, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:27.6750000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (32, 7, NULL, NULL, 31, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:27.7400000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (33, NULL, 37, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:27.7550000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (34, 8, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:27.7800000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (35, 8, NULL, NULL, 34, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:27.7830000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (36, NULL, 43, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:27.9460000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (37, 9, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:27.9920000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (38, 9, NULL, NULL, 37, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.0130000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (39, NULL, 49, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.0190000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (40, 13, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.0520000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (41, 13, NULL, NULL, 40, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.0860000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (42, NULL, 73, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.1230000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (43, 14, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.1630000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (44, 14, NULL, NULL, 43, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.2140000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (45, NULL, 79, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.2590000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (46, 15, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.2800000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (47, 15, NULL, NULL, 46, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.2860000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (48, NULL, 85, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.2940000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (49, 16, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.3140000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (50, 16, NULL, NULL, 49, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.3380000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (51, NULL, 91, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.3560000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (52, 17, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.3800000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (53, 17, NULL, NULL, 52, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.4050000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (54, NULL, 97, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.4430000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (55, 18, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.4730000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (56, 18, NULL, NULL, 55, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.4880000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (57, NULL, 103, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.4920000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (58, 19, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.4970000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (59, 19, NULL, NULL, 58, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.5060000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (60, NULL, 109, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.5090000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (61, 20, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.5120000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (62, 20, NULL, NULL, 61, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.5170000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (63, NULL, 115, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.5190000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (64, 21, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.5230000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (65, 21, NULL, NULL, 64, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.5270000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (66, NULL, 121, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.5310000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (67, 25, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.5420000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (68, 25, NULL, NULL, 67, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.5630000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (69, NULL, 145, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.5860000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (70, 26, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.6390000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (71, 26, NULL, NULL, 70, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.7080000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (72, NULL, 151, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.7360000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (73, 27, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.7520000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (74, 27, NULL, NULL, 73, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.7560000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (75, NULL, 157, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.7600000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (76, 28, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.7630000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (77, 28, NULL, NULL, 76, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.7670000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (78, NULL, 163, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.7730000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (79, 29, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.7760000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (80, 29, NULL, NULL, 79, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.7790000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (81, NULL, 169, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.7820000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (82, 30, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.7880000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (83, 30, NULL, NULL, 82, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.7920000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (84, NULL, 175, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.8040000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (85, 31, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.8840000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (86, 31, NULL, NULL, 85, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:28.9700000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (87, NULL, 181, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:28.9820000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (88, 32, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:28.9970000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (89, 32, NULL, NULL, 88, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.0070000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (90, NULL, 187, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.0100000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (91, 33, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.0130000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (92, 33, NULL, NULL, 91, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.0520000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (93, NULL, 193, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.1610000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (94, 37, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.2310000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (95, 37, NULL, NULL, 94, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.2550000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (96, NULL, 217, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.2740000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (97, 38, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.2790000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (98, 38, NULL, NULL, 97, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.2820000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (99, NULL, 223, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.2860000' AS DateTime2))
GO
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (100, 39, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.2930000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (101, 39, NULL, NULL, 100, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.3020000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (102, NULL, 229, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.3290000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (103, 40, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.3770000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (104, 40, NULL, NULL, 103, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.4420000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (105, NULL, 235, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.4810000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (106, 41, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.5000000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (107, 41, NULL, NULL, 106, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.5040000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (108, NULL, 241, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.5060000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (109, 42, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.5100000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (110, 42, NULL, NULL, 109, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.5130000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (111, NULL, 247, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.5150000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (112, 43, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.5180000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (113, 43, NULL, NULL, 112, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.5200000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (114, NULL, 253, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.5230000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (115, 44, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.5260000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (116, 44, NULL, NULL, 115, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.5300000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (117, NULL, 259, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.5310000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (118, 45, NULL, NULL, NULL, 5, N'Mình thích bối cảnh của truyện. Đây là bình luận mẫu để thử trả lời và báo cáo.', 0, CAST(N'2026-10-08T14:08:29.5330000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (119, 45, NULL, NULL, 118, 6, N'Mình cũng vậy! Bạn đã đọc đến chương 3 chưa?', 0, CAST(N'2026-10-08T14:08:29.5360000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (120, NULL, 265, NULL, NULL, 7, N'Chương mở đầu rõ ràng, mình sẽ đọc tiếp. [Dữ liệu mẫu]', 0, CAST(N'2026-10-08T14:08:29.5390000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (121, NULL, NULL, 1, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:29.6980000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (122, NULL, NULL, 1, 121, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:29.7590000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (123, NULL, NULL, 2, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:29.7780000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (124, NULL, NULL, 2, 123, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:29.7860000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (125, NULL, NULL, 3, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:29.7940000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (126, NULL, NULL, 3, 125, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:29.8000000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (127, NULL, NULL, 4, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:29.8070000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (128, NULL, NULL, 4, 127, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:29.8100000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (129, NULL, NULL, 5, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.0310000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (130, NULL, NULL, 5, 129, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.0910000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (131, NULL, NULL, 6, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.1900000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (132, NULL, NULL, 6, 131, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.2570000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (133, NULL, NULL, 7, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.3300000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (134, NULL, NULL, 7, 133, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.3360000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (135, NULL, NULL, 8, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.3580000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (136, NULL, NULL, 8, 135, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.3620000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (137, NULL, NULL, 9, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.3700000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (138, NULL, NULL, 9, 137, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.3730000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (139, NULL, NULL, 10, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.3880000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (140, NULL, NULL, 10, 139, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.3940000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (141, NULL, NULL, 11, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.4050000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (142, NULL, NULL, 11, 141, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.4120000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (143, NULL, NULL, 12, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.4260000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (144, NULL, NULL, 12, 143, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.4850000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (145, NULL, NULL, 13, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.5370000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (146, NULL, NULL, 13, 145, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.5730000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (147, NULL, NULL, 14, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.5950000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (148, NULL, NULL, 14, 147, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.5980000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (149, NULL, NULL, 15, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.6090000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (150, NULL, NULL, 15, 149, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.6120000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (151, NULL, NULL, 16, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.6190000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (152, NULL, NULL, 16, 151, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.6210000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (153, NULL, NULL, 17, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.6310000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (154, NULL, NULL, 17, 153, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.6330000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (155, NULL, NULL, 18, NULL, 5, N'Mình thường dành 20 phút đọc trước khi đi ngủ. [Bình luận mẫu]', 0, CAST(N'2026-10-08T14:08:30.6420000' AS DateTime2))
INSERT [dbo].[BinhLuan] ([MaBinhLuan], [MaSach], [MaChuong], [MaBaiThaoLuan], [MaBinhLuanCha], [MaTaiKhoan], [NoiDung], [BiAn], [NgayTao]) VALUES (156, NULL, NULL, 18, 155, 6, N'Ý hay, mình sẽ thử và quay lại chia sẻ.', 0, CAST(N'2026-10-08T14:08:30.6450000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[BinhLuan] OFF
GO
SET IDENTITY_INSERT [dbo].[Chuong] ON 

INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (1, 1, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (2, 1, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (3, 1, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (4, 1, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (5, 1, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (6, 1, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (7, 2, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (8, 2, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (9, 2, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (10, 2, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (11, 2, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (12, 2, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (13, 3, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (14, 3, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (15, 3, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (16, 3, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (17, 3, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (18, 3, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (19, 4, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (20, 4, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (21, 4, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (22, 4, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (23, 4, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (24, 4, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (25, 5, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (26, 5, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (27, 5, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (28, 5, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (29, 5, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (30, 5, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (31, 6, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (32, 6, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (33, 6, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (34, 6, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (35, 6, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (36, 6, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (37, 7, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (38, 7, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (39, 7, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (40, 7, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (41, 7, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (42, 7, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (43, 8, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (44, 8, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (45, 8, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (46, 8, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (47, 8, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (48, 8, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (49, 9, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (50, 9, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (51, 9, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (52, 9, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (53, 9, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (54, 9, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (55, 10, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (56, 10, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (57, 10, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (58, 10, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (59, 10, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (60, 10, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (61, 11, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (62, 11, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (63, 11, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (64, 11, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (65, 11, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (66, 11, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (67, 12, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (68, 12, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (69, 12, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (70, 12, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (71, 12, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (72, 12, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (73, 13, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (74, 13, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (75, 13, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (76, 13, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (77, 13, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (78, 13, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (79, 14, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (80, 14, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (81, 14, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (82, 14, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (83, 14, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (84, 14, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (85, 15, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (86, 15, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (87, 15, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (88, 15, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (89, 15, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (90, 15, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (91, 16, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (92, 16, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (93, 16, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (94, 16, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (95, 16, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (96, 16, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (97, 17, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (98, 17, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (99, 17, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
GO
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (100, 17, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (101, 17, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (102, 17, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (103, 18, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (104, 18, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (105, 18, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (106, 18, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (107, 18, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (108, 18, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (109, 19, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (110, 19, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (111, 19, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (112, 19, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (113, 19, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (114, 19, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (115, 20, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (116, 20, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (117, 20, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (118, 20, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (119, 20, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (120, 20, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (121, 21, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (122, 21, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (123, 21, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (124, 21, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (125, 21, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (126, 21, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (127, 22, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (128, 22, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (129, 22, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (130, 22, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (131, 22, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (132, 22, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (133, 23, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (134, 23, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (135, 23, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (136, 23, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (137, 23, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (138, 23, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (139, 24, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (140, 24, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (141, 24, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (142, 24, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (143, 24, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (144, 24, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (145, 25, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (146, 25, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (147, 25, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (148, 25, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (149, 25, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (150, 25, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (151, 26, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (152, 26, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (153, 26, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (154, 26, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (155, 26, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (156, 26, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (157, 27, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (158, 27, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (159, 27, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (160, 27, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (161, 27, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (162, 27, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (163, 28, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (164, 28, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (165, 28, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (166, 28, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (167, 28, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (168, 28, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (169, 29, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (170, 29, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (171, 29, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (172, 29, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (173, 29, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (174, 29, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (175, 30, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (176, 30, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (177, 30, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (178, 30, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (179, 30, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (180, 30, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (181, 31, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (182, 31, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (183, 31, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (184, 31, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (185, 31, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (186, 31, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (187, 32, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (188, 32, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (189, 32, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (190, 32, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (191, 32, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (192, 32, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (193, 33, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (194, 33, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (195, 33, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (196, 33, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (197, 33, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (198, 33, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (199, 34, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
GO
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (200, 34, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (201, 34, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (202, 34, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (203, 34, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (204, 34, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (205, 35, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (206, 35, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (207, 35, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (208, 35, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (209, 35, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (210, 35, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (211, 36, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (212, 36, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (213, 36, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (214, 36, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (215, 36, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (216, 36, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (217, 37, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (218, 37, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (219, 37, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (220, 37, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (221, 37, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (222, 37, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (223, 38, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (224, 38, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (225, 38, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (226, 38, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (227, 38, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (228, 38, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (229, 39, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (230, 39, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (231, 39, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (232, 39, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (233, 39, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (234, 39, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (235, 40, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (236, 40, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (237, 40, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (238, 40, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (239, 40, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (240, 40, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (241, 41, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (242, 41, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (243, 41, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (244, 41, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (245, 41, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (246, 41, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (247, 42, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (248, 42, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (249, 42, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (250, 42, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (251, 42, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (252, 42, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (253, 43, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (254, 43, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (255, 43, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (256, 43, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (257, 43, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (258, 43, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (259, 44, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (260, 44, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (261, 44, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (262, 44, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (263, 44, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (264, 44, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (265, 45, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (266, 45, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (267, 45, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (268, 45, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (269, 45, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (270, 45, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (271, 46, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (272, 46, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (273, 46, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (274, 46, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (275, 46, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (276, 46, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (277, 47, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (278, 47, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (279, 47, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (280, 47, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (281, 47, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (282, 47, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (283, 48, 1, N'Tín hiệu đầu tiên', CAST(N'2026-09-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (284, 48, 2, N'Một người bạn mới', CAST(N'2026-09-12T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (285, 48, 3, N'Dấu vết còn lại', CAST(N'2026-09-13T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (286, 48, 4, N'Lựa chọn giữa đường', CAST(N'2026-09-14T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (287, 48, 5, N'Cùng nhau tìm lời giải', CAST(N'2026-09-15T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[Chuong] ([MaChuong], [MaSach], [SoChuong], [TieuDe], [NgayTao]) VALUES (288, 48, 6, N'Ngày mới bắt đầu', CAST(N'2026-09-16T14:08:15.5400000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[Chuong] OFF
GO
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 1, 3, CAST(N'2026-10-11T14:08:24.8030000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 2, 4, CAST(N'2026-10-11T14:08:24.8470000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 3, 5, CAST(N'2026-10-11T14:08:24.8740000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 4, 3, CAST(N'2026-10-11T14:08:24.8810000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 5, 4, CAST(N'2026-10-11T14:08:24.8830000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 6, 5, CAST(N'2026-10-11T14:08:24.8840000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 7, 3, CAST(N'2026-10-11T14:08:24.8850000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 8, 4, CAST(N'2026-10-11T14:08:24.8850000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 9, 5, CAST(N'2026-10-11T14:08:24.8890000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 13, 3, CAST(N'2026-10-11T14:08:24.8890000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 14, 4, CAST(N'2026-10-11T14:08:24.8890000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (5, 15, 5, CAST(N'2026-10-11T14:08:24.8900000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 9, 4, CAST(N'2026-10-11T14:08:24.8910000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 13, 5, CAST(N'2026-10-11T14:08:24.8920000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 14, 3, CAST(N'2026-10-11T14:08:24.8940000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 15, 4, CAST(N'2026-10-11T14:08:24.8950000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 16, 5, CAST(N'2026-10-11T14:08:24.8970000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 17, 3, CAST(N'2026-10-11T14:08:24.8980000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 18, 4, CAST(N'2026-10-11T14:08:24.8990000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 19, 5, CAST(N'2026-10-11T14:08:24.8990000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 20, 3, CAST(N'2026-10-11T14:08:24.8990000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 21, 4, CAST(N'2026-10-11T14:08:24.9000000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 25, 5, CAST(N'2026-10-11T14:08:24.9000000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (6, 26, 3, CAST(N'2026-10-11T14:08:24.9000000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 20, 5, CAST(N'2026-10-11T14:08:24.9010000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 21, 3, CAST(N'2026-10-11T14:08:24.9020000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 25, 4, CAST(N'2026-10-11T14:08:24.9030000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 26, 5, CAST(N'2026-10-11T14:08:24.9040000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 27, 3, CAST(N'2026-10-11T14:08:24.9050000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 28, 4, CAST(N'2026-10-11T14:08:24.9070000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 29, 5, CAST(N'2026-10-11T14:08:24.9100000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 30, 3, CAST(N'2026-10-11T14:08:24.9120000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 31, 4, CAST(N'2026-10-11T14:08:24.9130000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 32, 5, CAST(N'2026-10-11T14:08:24.9130000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 33, 3, CAST(N'2026-10-11T14:08:24.9140000' AS DateTime2))
INSERT [dbo].[DanhGia] ([MaTaiKhoan], [MaSach], [SoSao], [NgayDanhGia]) VALUES (7, 37, 4, CAST(N'2026-10-11T14:08:24.9140000' AS DateTime2))
GO
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (5, 1, 1, CAST(N'2026-10-11T14:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (5, 2, 8, CAST(N'2026-10-11T13:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (5, 3, 15, CAST(N'2026-10-11T12:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (5, 4, 22, CAST(N'2026-10-11T11:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (5, 5, 29, CAST(N'2026-10-11T10:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (5, 6, 36, CAST(N'2026-10-11T09:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (6, 9, 49, CAST(N'2026-10-11T13:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (6, 13, 74, CAST(N'2026-10-11T12:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (6, 14, 81, CAST(N'2026-10-11T11:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (6, 15, 88, CAST(N'2026-10-11T10:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (6, 16, 95, CAST(N'2026-10-11T09:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (6, 17, 102, CAST(N'2026-10-11T08:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (7, 20, 115, CAST(N'2026-10-11T12:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (7, 21, 122, CAST(N'2026-10-11T11:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (7, 25, 147, CAST(N'2026-10-11T10:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (7, 26, 154, CAST(N'2026-10-11T09:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (7, 27, 161, CAST(N'2026-10-11T08:08:15.5400000' AS DateTime2))
INSERT [dbo].[LichSuDoc] ([MaTaiKhoan], [MaSach], [MaChuong], [LanDocCuoi]) VALUES (7, 28, 168, CAST(N'2026-10-11T07:08:15.5400000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[LuotDocSach] ON 

INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1, 1, 5, NULL, CAST(N'2026-10-11T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (2, 1, 5, NULL, CAST(N'2026-10-10T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (3, 1, 5, NULL, CAST(N'2026-10-09T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (4, 1, 5, NULL, CAST(N'2026-10-08T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (5, 1, 5, NULL, CAST(N'2026-10-07T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (6, 1, 5, NULL, CAST(N'2026-10-06T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (7, 1, 5, NULL, CAST(N'2026-10-05T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (8, 1, 5, NULL, CAST(N'2026-10-04T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (9, 1, 5, NULL, CAST(N'2026-10-03T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (10, 1, 5, NULL, CAST(N'2026-10-02T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (11, 1, 5, NULL, CAST(N'2026-10-01T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (12, 1, 5, NULL, CAST(N'2026-09-30T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (13, 1, 5, NULL, CAST(N'2026-09-29T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (14, 1, 5, NULL, CAST(N'2026-09-28T14:07:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (15, 2, 5, NULL, CAST(N'2026-10-11T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (16, 2, 6, NULL, CAST(N'2026-10-11T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (17, 2, 5, NULL, CAST(N'2026-10-10T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (18, 2, 6, NULL, CAST(N'2026-10-10T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (19, 2, 5, NULL, CAST(N'2026-10-09T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (20, 2, 6, NULL, CAST(N'2026-10-09T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (21, 2, 5, NULL, CAST(N'2026-10-08T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (22, 2, 6, NULL, CAST(N'2026-10-08T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (23, 2, 5, NULL, CAST(N'2026-10-07T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (24, 2, 6, NULL, CAST(N'2026-10-07T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (25, 2, 5, NULL, CAST(N'2026-10-06T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (26, 2, 6, NULL, CAST(N'2026-10-06T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (27, 2, 5, NULL, CAST(N'2026-10-05T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (28, 2, 6, NULL, CAST(N'2026-10-05T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (29, 2, 5, NULL, CAST(N'2026-10-04T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (30, 2, 6, NULL, CAST(N'2026-10-04T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (31, 2, 5, NULL, CAST(N'2026-10-03T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (32, 2, 6, NULL, CAST(N'2026-10-03T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (33, 2, 5, NULL, CAST(N'2026-10-02T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (34, 2, 6, NULL, CAST(N'2026-10-02T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (35, 2, 5, NULL, CAST(N'2026-10-01T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (36, 2, 6, NULL, CAST(N'2026-10-01T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (37, 2, 5, NULL, CAST(N'2026-09-30T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (38, 2, 6, NULL, CAST(N'2026-09-30T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (39, 2, 5, NULL, CAST(N'2026-09-29T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (40, 2, 6, NULL, CAST(N'2026-09-29T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (41, 2, 5, NULL, CAST(N'2026-09-28T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (42, 2, 6, NULL, CAST(N'2026-09-28T14:06:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (43, 3, 5, NULL, CAST(N'2026-10-11T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (44, 3, 6, NULL, CAST(N'2026-10-11T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (45, 3, 7, NULL, CAST(N'2026-10-11T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (46, 3, 5, NULL, CAST(N'2026-10-10T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (47, 3, 6, NULL, CAST(N'2026-10-10T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (48, 3, 7, NULL, CAST(N'2026-10-10T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (49, 3, 5, NULL, CAST(N'2026-10-09T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (50, 3, 6, NULL, CAST(N'2026-10-09T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (51, 3, 7, NULL, CAST(N'2026-10-09T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (52, 3, 5, NULL, CAST(N'2026-10-08T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (53, 3, 6, NULL, CAST(N'2026-10-08T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (54, 3, 7, NULL, CAST(N'2026-10-08T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (55, 3, 5, NULL, CAST(N'2026-10-07T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (56, 3, 6, NULL, CAST(N'2026-10-07T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (57, 3, 7, NULL, CAST(N'2026-10-07T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (58, 3, 5, NULL, CAST(N'2026-10-06T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (59, 3, 6, NULL, CAST(N'2026-10-06T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (60, 3, 7, NULL, CAST(N'2026-10-06T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (61, 3, 5, NULL, CAST(N'2026-10-05T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (62, 3, 6, NULL, CAST(N'2026-10-05T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (63, 3, 7, NULL, CAST(N'2026-10-05T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (64, 3, 5, NULL, CAST(N'2026-10-04T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (65, 3, 6, NULL, CAST(N'2026-10-04T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (66, 3, 7, NULL, CAST(N'2026-10-04T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (67, 3, 5, NULL, CAST(N'2026-10-03T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (68, 3, 6, NULL, CAST(N'2026-10-03T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (69, 3, 7, NULL, CAST(N'2026-10-03T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (70, 3, 5, NULL, CAST(N'2026-10-02T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (71, 3, 6, NULL, CAST(N'2026-10-02T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (72, 3, 7, NULL, CAST(N'2026-10-02T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (73, 3, 5, NULL, CAST(N'2026-10-01T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (74, 3, 6, NULL, CAST(N'2026-10-01T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (75, 3, 7, NULL, CAST(N'2026-10-01T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (76, 3, 5, NULL, CAST(N'2026-09-30T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (77, 3, 6, NULL, CAST(N'2026-09-30T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (78, 3, 7, NULL, CAST(N'2026-09-30T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (79, 3, 5, NULL, CAST(N'2026-09-29T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (80, 3, 6, NULL, CAST(N'2026-09-29T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (81, 3, 7, NULL, CAST(N'2026-09-29T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (82, 3, 5, NULL, CAST(N'2026-09-28T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (83, 3, 6, NULL, CAST(N'2026-09-28T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (84, 3, 7, NULL, CAST(N'2026-09-28T14:05:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (85, 4, 5, NULL, CAST(N'2026-10-11T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (86, 4, 5, NULL, CAST(N'2026-10-10T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (87, 4, 5, NULL, CAST(N'2026-10-09T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (88, 4, 5, NULL, CAST(N'2026-10-08T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (89, 4, 5, NULL, CAST(N'2026-10-07T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (90, 4, 5, NULL, CAST(N'2026-10-06T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (91, 4, 5, NULL, CAST(N'2026-10-05T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (92, 4, 5, NULL, CAST(N'2026-10-04T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (93, 4, 5, NULL, CAST(N'2026-10-03T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (94, 4, 5, NULL, CAST(N'2026-10-02T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (95, 4, 5, NULL, CAST(N'2026-10-01T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (96, 4, 5, NULL, CAST(N'2026-09-30T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (97, 4, 5, NULL, CAST(N'2026-09-29T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (98, 4, 5, NULL, CAST(N'2026-09-28T14:04:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (99, 5, 5, NULL, CAST(N'2026-10-11T14:03:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (100, 5, 6, NULL, CAST(N'2026-10-11T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (101, 5, 5, NULL, CAST(N'2026-10-10T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (102, 5, 6, NULL, CAST(N'2026-10-10T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (103, 5, 5, NULL, CAST(N'2026-10-09T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (104, 5, 6, NULL, CAST(N'2026-10-09T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (105, 5, 5, NULL, CAST(N'2026-10-08T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (106, 5, 6, NULL, CAST(N'2026-10-08T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (107, 5, 5, NULL, CAST(N'2026-10-07T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (108, 5, 6, NULL, CAST(N'2026-10-07T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (109, 5, 5, NULL, CAST(N'2026-10-06T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (110, 5, 6, NULL, CAST(N'2026-10-06T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (111, 5, 5, NULL, CAST(N'2026-10-05T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (112, 5, 6, NULL, CAST(N'2026-10-05T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (113, 5, 5, NULL, CAST(N'2026-10-04T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (114, 5, 6, NULL, CAST(N'2026-10-04T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (115, 5, 5, NULL, CAST(N'2026-10-03T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (116, 5, 6, NULL, CAST(N'2026-10-03T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (117, 5, 5, NULL, CAST(N'2026-10-02T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (118, 5, 6, NULL, CAST(N'2026-10-02T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (119, 5, 5, NULL, CAST(N'2026-10-01T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (120, 5, 6, NULL, CAST(N'2026-10-01T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (121, 5, 5, NULL, CAST(N'2026-09-30T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (122, 5, 6, NULL, CAST(N'2026-09-30T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (123, 5, 5, NULL, CAST(N'2026-09-29T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (124, 5, 6, NULL, CAST(N'2026-09-29T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (125, 5, 5, NULL, CAST(N'2026-09-28T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (126, 5, 6, NULL, CAST(N'2026-09-28T14:03:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (127, 6, 5, NULL, CAST(N'2026-10-11T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (128, 6, 6, NULL, CAST(N'2026-10-11T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (129, 6, 7, NULL, CAST(N'2026-10-11T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (130, 6, 5, NULL, CAST(N'2026-10-10T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (131, 6, 6, NULL, CAST(N'2026-10-10T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (132, 6, 7, NULL, CAST(N'2026-10-10T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (133, 6, 5, NULL, CAST(N'2026-10-09T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (134, 6, 6, NULL, CAST(N'2026-10-09T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (135, 6, 7, NULL, CAST(N'2026-10-09T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (136, 6, 5, NULL, CAST(N'2026-10-08T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (137, 6, 6, NULL, CAST(N'2026-10-08T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (138, 6, 7, NULL, CAST(N'2026-10-08T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (139, 6, 5, NULL, CAST(N'2026-10-07T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (140, 6, 6, NULL, CAST(N'2026-10-07T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (141, 6, 7, NULL, CAST(N'2026-10-07T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (142, 6, 5, NULL, CAST(N'2026-10-06T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (143, 6, 6, NULL, CAST(N'2026-10-06T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (144, 6, 7, NULL, CAST(N'2026-10-06T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (145, 6, 5, NULL, CAST(N'2026-10-05T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (146, 6, 6, NULL, CAST(N'2026-10-05T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (147, 6, 7, NULL, CAST(N'2026-10-05T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (148, 6, 5, NULL, CAST(N'2026-10-04T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (149, 6, 6, NULL, CAST(N'2026-10-04T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (150, 6, 7, NULL, CAST(N'2026-10-04T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (151, 6, 5, NULL, CAST(N'2026-10-03T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (152, 6, 6, NULL, CAST(N'2026-10-03T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (153, 6, 7, NULL, CAST(N'2026-10-03T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (154, 6, 5, NULL, CAST(N'2026-10-02T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (155, 6, 6, NULL, CAST(N'2026-10-02T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (156, 6, 7, NULL, CAST(N'2026-10-02T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (157, 6, 5, NULL, CAST(N'2026-10-01T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (158, 6, 6, NULL, CAST(N'2026-10-01T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (159, 6, 7, NULL, CAST(N'2026-10-01T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (160, 6, 5, NULL, CAST(N'2026-09-30T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (161, 6, 6, NULL, CAST(N'2026-09-30T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (162, 6, 7, NULL, CAST(N'2026-09-30T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (163, 6, 5, NULL, CAST(N'2026-09-29T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (164, 6, 6, NULL, CAST(N'2026-09-29T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (165, 6, 7, NULL, CAST(N'2026-09-29T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (166, 6, 5, NULL, CAST(N'2026-09-28T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (167, 6, 6, NULL, CAST(N'2026-09-28T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (168, 6, 7, NULL, CAST(N'2026-09-28T14:02:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (169, 7, 5, NULL, CAST(N'2026-10-11T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (170, 7, 5, NULL, CAST(N'2026-10-10T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (171, 7, 5, NULL, CAST(N'2026-10-09T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (172, 7, 5, NULL, CAST(N'2026-10-08T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (173, 7, 5, NULL, CAST(N'2026-10-07T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (174, 7, 5, NULL, CAST(N'2026-10-06T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (175, 7, 5, NULL, CAST(N'2026-10-05T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (176, 7, 5, NULL, CAST(N'2026-10-04T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (177, 7, 5, NULL, CAST(N'2026-10-03T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (178, 7, 5, NULL, CAST(N'2026-10-02T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (179, 7, 5, NULL, CAST(N'2026-10-01T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (180, 7, 5, NULL, CAST(N'2026-09-30T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (181, 7, 5, NULL, CAST(N'2026-09-29T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (182, 7, 5, NULL, CAST(N'2026-09-28T14:01:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (183, 8, 5, NULL, CAST(N'2026-10-11T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (184, 8, 6, NULL, CAST(N'2026-10-11T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (185, 8, 5, NULL, CAST(N'2026-10-10T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (186, 8, 6, NULL, CAST(N'2026-10-10T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (187, 8, 5, NULL, CAST(N'2026-10-09T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (188, 8, 6, NULL, CAST(N'2026-10-09T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (189, 8, 5, NULL, CAST(N'2026-10-08T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (190, 8, 6, NULL, CAST(N'2026-10-08T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (191, 8, 5, NULL, CAST(N'2026-10-07T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (192, 8, 6, NULL, CAST(N'2026-10-07T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (193, 8, 5, NULL, CAST(N'2026-10-06T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (194, 8, 6, NULL, CAST(N'2026-10-06T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (195, 8, 5, NULL, CAST(N'2026-10-05T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (196, 8, 6, NULL, CAST(N'2026-10-05T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (197, 8, 5, NULL, CAST(N'2026-10-04T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (198, 8, 6, NULL, CAST(N'2026-10-04T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (199, 8, 5, NULL, CAST(N'2026-10-03T14:00:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (200, 8, 6, NULL, CAST(N'2026-10-03T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (201, 8, 5, NULL, CAST(N'2026-10-02T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (202, 8, 6, NULL, CAST(N'2026-10-02T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (203, 8, 5, NULL, CAST(N'2026-10-01T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (204, 8, 6, NULL, CAST(N'2026-10-01T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (205, 8, 5, NULL, CAST(N'2026-09-30T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (206, 8, 6, NULL, CAST(N'2026-09-30T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (207, 8, 5, NULL, CAST(N'2026-09-29T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (208, 8, 6, NULL, CAST(N'2026-09-29T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (209, 8, 5, NULL, CAST(N'2026-09-28T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (210, 8, 6, NULL, CAST(N'2026-09-28T14:00:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (211, 9, 5, NULL, CAST(N'2026-10-11T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (212, 9, 6, NULL, CAST(N'2026-10-11T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (213, 9, 7, NULL, CAST(N'2026-10-11T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (214, 9, 5, NULL, CAST(N'2026-10-10T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (215, 9, 6, NULL, CAST(N'2026-10-10T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (216, 9, 7, NULL, CAST(N'2026-10-10T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (217, 9, 5, NULL, CAST(N'2026-10-09T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (218, 9, 6, NULL, CAST(N'2026-10-09T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (219, 9, 7, NULL, CAST(N'2026-10-09T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (220, 9, 5, NULL, CAST(N'2026-10-08T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (221, 9, 6, NULL, CAST(N'2026-10-08T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (222, 9, 7, NULL, CAST(N'2026-10-08T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (223, 9, 5, NULL, CAST(N'2026-10-07T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (224, 9, 6, NULL, CAST(N'2026-10-07T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (225, 9, 7, NULL, CAST(N'2026-10-07T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (226, 9, 5, NULL, CAST(N'2026-10-06T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (227, 9, 6, NULL, CAST(N'2026-10-06T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (228, 9, 7, NULL, CAST(N'2026-10-06T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (229, 9, 5, NULL, CAST(N'2026-10-05T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (230, 9, 6, NULL, CAST(N'2026-10-05T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (231, 9, 7, NULL, CAST(N'2026-10-05T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (232, 9, 5, NULL, CAST(N'2026-10-04T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (233, 9, 6, NULL, CAST(N'2026-10-04T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (234, 9, 7, NULL, CAST(N'2026-10-04T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (235, 9, 5, NULL, CAST(N'2026-10-03T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (236, 9, 6, NULL, CAST(N'2026-10-03T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (237, 9, 7, NULL, CAST(N'2026-10-03T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (238, 9, 5, NULL, CAST(N'2026-10-02T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (239, 9, 6, NULL, CAST(N'2026-10-02T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (240, 9, 7, NULL, CAST(N'2026-10-02T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (241, 9, 5, NULL, CAST(N'2026-10-01T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (242, 9, 6, NULL, CAST(N'2026-10-01T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (243, 9, 7, NULL, CAST(N'2026-10-01T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (244, 9, 5, NULL, CAST(N'2026-09-30T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (245, 9, 6, NULL, CAST(N'2026-09-30T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (246, 9, 7, NULL, CAST(N'2026-09-30T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (247, 9, 5, NULL, CAST(N'2026-09-29T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (248, 9, 6, NULL, CAST(N'2026-09-29T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (249, 9, 7, NULL, CAST(N'2026-09-29T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (250, 9, 5, NULL, CAST(N'2026-09-28T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (251, 9, 6, NULL, CAST(N'2026-09-28T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (252, 9, 7, NULL, CAST(N'2026-09-28T13:59:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (253, 13, 5, NULL, CAST(N'2026-10-11T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (254, 13, 5, NULL, CAST(N'2026-10-10T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (255, 13, 5, NULL, CAST(N'2026-10-09T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (256, 13, 5, NULL, CAST(N'2026-10-08T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (257, 13, 5, NULL, CAST(N'2026-10-07T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (258, 13, 5, NULL, CAST(N'2026-10-06T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (259, 13, 5, NULL, CAST(N'2026-10-05T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (260, 13, 5, NULL, CAST(N'2026-10-04T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (261, 13, 5, NULL, CAST(N'2026-10-03T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (262, 13, 5, NULL, CAST(N'2026-10-02T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (263, 13, 5, NULL, CAST(N'2026-10-01T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (264, 13, 5, NULL, CAST(N'2026-09-30T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (265, 13, 5, NULL, CAST(N'2026-09-29T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (266, 13, 5, NULL, CAST(N'2026-09-28T13:55:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (267, 14, 5, NULL, CAST(N'2026-10-11T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (268, 14, 6, NULL, CAST(N'2026-10-11T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (269, 14, 5, NULL, CAST(N'2026-10-10T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (270, 14, 6, NULL, CAST(N'2026-10-10T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (271, 14, 5, NULL, CAST(N'2026-10-09T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (272, 14, 6, NULL, CAST(N'2026-10-09T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (273, 14, 5, NULL, CAST(N'2026-10-08T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (274, 14, 6, NULL, CAST(N'2026-10-08T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (275, 14, 5, NULL, CAST(N'2026-10-07T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (276, 14, 6, NULL, CAST(N'2026-10-07T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (277, 14, 5, NULL, CAST(N'2026-10-06T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (278, 14, 6, NULL, CAST(N'2026-10-06T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (279, 14, 5, NULL, CAST(N'2026-10-05T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (280, 14, 6, NULL, CAST(N'2026-10-05T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (281, 14, 5, NULL, CAST(N'2026-10-04T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (282, 14, 6, NULL, CAST(N'2026-10-04T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (283, 14, 5, NULL, CAST(N'2026-10-03T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (284, 14, 6, NULL, CAST(N'2026-10-03T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (285, 14, 5, NULL, CAST(N'2026-10-02T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (286, 14, 6, NULL, CAST(N'2026-10-02T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (287, 14, 5, NULL, CAST(N'2026-10-01T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (288, 14, 6, NULL, CAST(N'2026-10-01T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (289, 14, 5, NULL, CAST(N'2026-09-30T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (290, 14, 6, NULL, CAST(N'2026-09-30T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (291, 14, 5, NULL, CAST(N'2026-09-29T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (292, 14, 6, NULL, CAST(N'2026-09-29T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (293, 14, 5, NULL, CAST(N'2026-09-28T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (294, 14, 6, NULL, CAST(N'2026-09-28T13:54:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (295, 15, 5, NULL, CAST(N'2026-10-11T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (296, 15, 6, NULL, CAST(N'2026-10-11T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (297, 15, 7, NULL, CAST(N'2026-10-11T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (298, 15, 5, NULL, CAST(N'2026-10-10T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (299, 15, 6, NULL, CAST(N'2026-10-10T13:53:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (300, 15, 7, NULL, CAST(N'2026-10-10T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (301, 15, 5, NULL, CAST(N'2026-10-09T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (302, 15, 6, NULL, CAST(N'2026-10-09T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (303, 15, 7, NULL, CAST(N'2026-10-09T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (304, 15, 5, NULL, CAST(N'2026-10-08T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (305, 15, 6, NULL, CAST(N'2026-10-08T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (306, 15, 7, NULL, CAST(N'2026-10-08T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (307, 15, 5, NULL, CAST(N'2026-10-07T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (308, 15, 6, NULL, CAST(N'2026-10-07T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (309, 15, 7, NULL, CAST(N'2026-10-07T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (310, 15, 5, NULL, CAST(N'2026-10-06T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (311, 15, 6, NULL, CAST(N'2026-10-06T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (312, 15, 7, NULL, CAST(N'2026-10-06T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (313, 15, 5, NULL, CAST(N'2026-10-05T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (314, 15, 6, NULL, CAST(N'2026-10-05T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (315, 15, 7, NULL, CAST(N'2026-10-05T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (316, 15, 5, NULL, CAST(N'2026-10-04T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (317, 15, 6, NULL, CAST(N'2026-10-04T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (318, 15, 7, NULL, CAST(N'2026-10-04T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (319, 15, 5, NULL, CAST(N'2026-10-03T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (320, 15, 6, NULL, CAST(N'2026-10-03T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (321, 15, 7, NULL, CAST(N'2026-10-03T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (322, 15, 5, NULL, CAST(N'2026-10-02T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (323, 15, 6, NULL, CAST(N'2026-10-02T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (324, 15, 7, NULL, CAST(N'2026-10-02T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (325, 15, 5, NULL, CAST(N'2026-10-01T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (326, 15, 6, NULL, CAST(N'2026-10-01T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (327, 15, 7, NULL, CAST(N'2026-10-01T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (328, 15, 5, NULL, CAST(N'2026-09-30T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (329, 15, 6, NULL, CAST(N'2026-09-30T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (330, 15, 7, NULL, CAST(N'2026-09-30T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (331, 15, 5, NULL, CAST(N'2026-09-29T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (332, 15, 6, NULL, CAST(N'2026-09-29T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (333, 15, 7, NULL, CAST(N'2026-09-29T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (334, 15, 5, NULL, CAST(N'2026-09-28T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (335, 15, 6, NULL, CAST(N'2026-09-28T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (336, 15, 7, NULL, CAST(N'2026-09-28T13:53:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (337, 16, 5, NULL, CAST(N'2026-10-11T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (338, 16, 5, NULL, CAST(N'2026-10-10T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (339, 16, 5, NULL, CAST(N'2026-10-09T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (340, 16, 5, NULL, CAST(N'2026-10-08T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (341, 16, 5, NULL, CAST(N'2026-10-07T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (342, 16, 5, NULL, CAST(N'2026-10-06T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (343, 16, 5, NULL, CAST(N'2026-10-05T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (344, 16, 5, NULL, CAST(N'2026-10-04T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (345, 16, 5, NULL, CAST(N'2026-10-03T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (346, 16, 5, NULL, CAST(N'2026-10-02T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (347, 16, 5, NULL, CAST(N'2026-10-01T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (348, 16, 5, NULL, CAST(N'2026-09-30T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (349, 16, 5, NULL, CAST(N'2026-09-29T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (350, 16, 5, NULL, CAST(N'2026-09-28T13:52:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (351, 17, 5, NULL, CAST(N'2026-10-11T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (352, 17, 6, NULL, CAST(N'2026-10-11T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (353, 17, 5, NULL, CAST(N'2026-10-10T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (354, 17, 6, NULL, CAST(N'2026-10-10T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (355, 17, 5, NULL, CAST(N'2026-10-09T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (356, 17, 6, NULL, CAST(N'2026-10-09T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (357, 17, 5, NULL, CAST(N'2026-10-08T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (358, 17, 6, NULL, CAST(N'2026-10-08T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (359, 17, 5, NULL, CAST(N'2026-10-07T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (360, 17, 6, NULL, CAST(N'2026-10-07T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (361, 17, 5, NULL, CAST(N'2026-10-06T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (362, 17, 6, NULL, CAST(N'2026-10-06T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (363, 17, 5, NULL, CAST(N'2026-10-05T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (364, 17, 6, NULL, CAST(N'2026-10-05T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (365, 17, 5, NULL, CAST(N'2026-10-04T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (366, 17, 6, NULL, CAST(N'2026-10-04T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (367, 17, 5, NULL, CAST(N'2026-10-03T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (368, 17, 6, NULL, CAST(N'2026-10-03T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (369, 17, 5, NULL, CAST(N'2026-10-02T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (370, 17, 6, NULL, CAST(N'2026-10-02T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (371, 17, 5, NULL, CAST(N'2026-10-01T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (372, 17, 6, NULL, CAST(N'2026-10-01T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (373, 17, 5, NULL, CAST(N'2026-09-30T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (374, 17, 6, NULL, CAST(N'2026-09-30T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (375, 17, 5, NULL, CAST(N'2026-09-29T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (376, 17, 6, NULL, CAST(N'2026-09-29T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (377, 17, 5, NULL, CAST(N'2026-09-28T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (378, 17, 6, NULL, CAST(N'2026-09-28T13:51:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (379, 18, 5, NULL, CAST(N'2026-10-11T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (380, 18, 6, NULL, CAST(N'2026-10-11T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (381, 18, 7, NULL, CAST(N'2026-10-11T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (382, 18, 5, NULL, CAST(N'2026-10-10T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (383, 18, 6, NULL, CAST(N'2026-10-10T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (384, 18, 7, NULL, CAST(N'2026-10-10T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (385, 18, 5, NULL, CAST(N'2026-10-09T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (386, 18, 6, NULL, CAST(N'2026-10-09T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (387, 18, 7, NULL, CAST(N'2026-10-09T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (388, 18, 5, NULL, CAST(N'2026-10-08T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (389, 18, 6, NULL, CAST(N'2026-10-08T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (390, 18, 7, NULL, CAST(N'2026-10-08T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (391, 18, 5, NULL, CAST(N'2026-10-07T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (392, 18, 6, NULL, CAST(N'2026-10-07T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (393, 18, 7, NULL, CAST(N'2026-10-07T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (394, 18, 5, NULL, CAST(N'2026-10-06T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (395, 18, 6, NULL, CAST(N'2026-10-06T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (396, 18, 7, NULL, CAST(N'2026-10-06T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (397, 18, 5, NULL, CAST(N'2026-10-05T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (398, 18, 6, NULL, CAST(N'2026-10-05T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (399, 18, 7, NULL, CAST(N'2026-10-05T13:50:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (400, 18, 5, NULL, CAST(N'2026-10-04T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (401, 18, 6, NULL, CAST(N'2026-10-04T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (402, 18, 7, NULL, CAST(N'2026-10-04T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (403, 18, 5, NULL, CAST(N'2026-10-03T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (404, 18, 6, NULL, CAST(N'2026-10-03T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (405, 18, 7, NULL, CAST(N'2026-10-03T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (406, 18, 5, NULL, CAST(N'2026-10-02T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (407, 18, 6, NULL, CAST(N'2026-10-02T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (408, 18, 7, NULL, CAST(N'2026-10-02T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (409, 18, 5, NULL, CAST(N'2026-10-01T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (410, 18, 6, NULL, CAST(N'2026-10-01T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (411, 18, 7, NULL, CAST(N'2026-10-01T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (412, 18, 5, NULL, CAST(N'2026-09-30T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (413, 18, 6, NULL, CAST(N'2026-09-30T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (414, 18, 7, NULL, CAST(N'2026-09-30T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (415, 18, 5, NULL, CAST(N'2026-09-29T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (416, 18, 6, NULL, CAST(N'2026-09-29T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (417, 18, 7, NULL, CAST(N'2026-09-29T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (418, 18, 5, NULL, CAST(N'2026-09-28T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (419, 18, 6, NULL, CAST(N'2026-09-28T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (420, 18, 7, NULL, CAST(N'2026-09-28T13:50:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (421, 19, 5, NULL, CAST(N'2026-10-11T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (422, 19, 5, NULL, CAST(N'2026-10-10T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (423, 19, 5, NULL, CAST(N'2026-10-09T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (424, 19, 5, NULL, CAST(N'2026-10-08T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (425, 19, 5, NULL, CAST(N'2026-10-07T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (426, 19, 5, NULL, CAST(N'2026-10-06T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (427, 19, 5, NULL, CAST(N'2026-10-05T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (428, 19, 5, NULL, CAST(N'2026-10-04T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (429, 19, 5, NULL, CAST(N'2026-10-03T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (430, 19, 5, NULL, CAST(N'2026-10-02T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (431, 19, 5, NULL, CAST(N'2026-10-01T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (432, 19, 5, NULL, CAST(N'2026-09-30T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (433, 19, 5, NULL, CAST(N'2026-09-29T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (434, 19, 5, NULL, CAST(N'2026-09-28T13:49:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (435, 20, 5, NULL, CAST(N'2026-10-11T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (436, 20, 6, NULL, CAST(N'2026-10-11T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (437, 20, 5, NULL, CAST(N'2026-10-10T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (438, 20, 6, NULL, CAST(N'2026-10-10T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (439, 20, 5, NULL, CAST(N'2026-10-09T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (440, 20, 6, NULL, CAST(N'2026-10-09T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (441, 20, 5, NULL, CAST(N'2026-10-08T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (442, 20, 6, NULL, CAST(N'2026-10-08T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (443, 20, 5, NULL, CAST(N'2026-10-07T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (444, 20, 6, NULL, CAST(N'2026-10-07T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (445, 20, 5, NULL, CAST(N'2026-10-06T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (446, 20, 6, NULL, CAST(N'2026-10-06T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (447, 20, 5, NULL, CAST(N'2026-10-05T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (448, 20, 6, NULL, CAST(N'2026-10-05T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (449, 20, 5, NULL, CAST(N'2026-10-04T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (450, 20, 6, NULL, CAST(N'2026-10-04T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (451, 20, 5, NULL, CAST(N'2026-10-03T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (452, 20, 6, NULL, CAST(N'2026-10-03T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (453, 20, 5, NULL, CAST(N'2026-10-02T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (454, 20, 6, NULL, CAST(N'2026-10-02T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (455, 20, 5, NULL, CAST(N'2026-10-01T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (456, 20, 6, NULL, CAST(N'2026-10-01T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (457, 20, 5, NULL, CAST(N'2026-09-30T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (458, 20, 6, NULL, CAST(N'2026-09-30T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (459, 20, 5, NULL, CAST(N'2026-09-29T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (460, 20, 6, NULL, CAST(N'2026-09-29T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (461, 20, 5, NULL, CAST(N'2026-09-28T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (462, 20, 6, NULL, CAST(N'2026-09-28T13:48:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (463, 21, 5, NULL, CAST(N'2026-10-11T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (464, 21, 6, NULL, CAST(N'2026-10-11T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (465, 21, 7, NULL, CAST(N'2026-10-11T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (466, 21, 5, NULL, CAST(N'2026-10-10T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (467, 21, 6, NULL, CAST(N'2026-10-10T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (468, 21, 7, NULL, CAST(N'2026-10-10T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (469, 21, 5, NULL, CAST(N'2026-10-09T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (470, 21, 6, NULL, CAST(N'2026-10-09T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (471, 21, 7, NULL, CAST(N'2026-10-09T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (472, 21, 5, NULL, CAST(N'2026-10-08T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (473, 21, 6, NULL, CAST(N'2026-10-08T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (474, 21, 7, NULL, CAST(N'2026-10-08T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (475, 21, 5, NULL, CAST(N'2026-10-07T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (476, 21, 6, NULL, CAST(N'2026-10-07T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (477, 21, 7, NULL, CAST(N'2026-10-07T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (478, 21, 5, NULL, CAST(N'2026-10-06T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (479, 21, 6, NULL, CAST(N'2026-10-06T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (480, 21, 7, NULL, CAST(N'2026-10-06T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (481, 21, 5, NULL, CAST(N'2026-10-05T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (482, 21, 6, NULL, CAST(N'2026-10-05T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (483, 21, 7, NULL, CAST(N'2026-10-05T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (484, 21, 5, NULL, CAST(N'2026-10-04T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (485, 21, 6, NULL, CAST(N'2026-10-04T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (486, 21, 7, NULL, CAST(N'2026-10-04T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (487, 21, 5, NULL, CAST(N'2026-10-03T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (488, 21, 6, NULL, CAST(N'2026-10-03T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (489, 21, 7, NULL, CAST(N'2026-10-03T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (490, 21, 5, NULL, CAST(N'2026-10-02T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (491, 21, 6, NULL, CAST(N'2026-10-02T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (492, 21, 7, NULL, CAST(N'2026-10-02T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (493, 21, 5, NULL, CAST(N'2026-10-01T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (494, 21, 6, NULL, CAST(N'2026-10-01T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (495, 21, 7, NULL, CAST(N'2026-10-01T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (496, 21, 5, NULL, CAST(N'2026-09-30T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (497, 21, 6, NULL, CAST(N'2026-09-30T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (498, 21, 7, NULL, CAST(N'2026-09-30T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (499, 21, 5, NULL, CAST(N'2026-09-29T13:47:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (500, 21, 6, NULL, CAST(N'2026-09-29T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (501, 21, 7, NULL, CAST(N'2026-09-29T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (502, 21, 5, NULL, CAST(N'2026-09-28T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (503, 21, 6, NULL, CAST(N'2026-09-28T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (504, 21, 7, NULL, CAST(N'2026-09-28T13:47:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (505, 25, 5, NULL, CAST(N'2026-10-11T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (506, 25, 5, NULL, CAST(N'2026-10-10T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (507, 25, 5, NULL, CAST(N'2026-10-09T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (508, 25, 5, NULL, CAST(N'2026-10-08T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (509, 25, 5, NULL, CAST(N'2026-10-07T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (510, 25, 5, NULL, CAST(N'2026-10-06T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (511, 25, 5, NULL, CAST(N'2026-10-05T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (512, 25, 5, NULL, CAST(N'2026-10-04T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (513, 25, 5, NULL, CAST(N'2026-10-03T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (514, 25, 5, NULL, CAST(N'2026-10-02T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (515, 25, 5, NULL, CAST(N'2026-10-01T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (516, 25, 5, NULL, CAST(N'2026-09-30T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (517, 25, 5, NULL, CAST(N'2026-09-29T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (518, 25, 5, NULL, CAST(N'2026-09-28T13:43:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (519, 26, 5, NULL, CAST(N'2026-10-11T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (520, 26, 6, NULL, CAST(N'2026-10-11T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (521, 26, 5, NULL, CAST(N'2026-10-10T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (522, 26, 6, NULL, CAST(N'2026-10-10T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (523, 26, 5, NULL, CAST(N'2026-10-09T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (524, 26, 6, NULL, CAST(N'2026-10-09T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (525, 26, 5, NULL, CAST(N'2026-10-08T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (526, 26, 6, NULL, CAST(N'2026-10-08T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (527, 26, 5, NULL, CAST(N'2026-10-07T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (528, 26, 6, NULL, CAST(N'2026-10-07T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (529, 26, 5, NULL, CAST(N'2026-10-06T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (530, 26, 6, NULL, CAST(N'2026-10-06T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (531, 26, 5, NULL, CAST(N'2026-10-05T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (532, 26, 6, NULL, CAST(N'2026-10-05T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (533, 26, 5, NULL, CAST(N'2026-10-04T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (534, 26, 6, NULL, CAST(N'2026-10-04T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (535, 26, 5, NULL, CAST(N'2026-10-03T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (536, 26, 6, NULL, CAST(N'2026-10-03T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (537, 26, 5, NULL, CAST(N'2026-10-02T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (538, 26, 6, NULL, CAST(N'2026-10-02T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (539, 26, 5, NULL, CAST(N'2026-10-01T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (540, 26, 6, NULL, CAST(N'2026-10-01T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (541, 26, 5, NULL, CAST(N'2026-09-30T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (542, 26, 6, NULL, CAST(N'2026-09-30T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (543, 26, 5, NULL, CAST(N'2026-09-29T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (544, 26, 6, NULL, CAST(N'2026-09-29T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (545, 26, 5, NULL, CAST(N'2026-09-28T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (546, 26, 6, NULL, CAST(N'2026-09-28T13:42:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (547, 27, 5, NULL, CAST(N'2026-10-11T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (548, 27, 6, NULL, CAST(N'2026-10-11T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (549, 27, 7, NULL, CAST(N'2026-10-11T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (550, 27, 5, NULL, CAST(N'2026-10-10T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (551, 27, 6, NULL, CAST(N'2026-10-10T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (552, 27, 7, NULL, CAST(N'2026-10-10T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (553, 27, 5, NULL, CAST(N'2026-10-09T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (554, 27, 6, NULL, CAST(N'2026-10-09T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (555, 27, 7, NULL, CAST(N'2026-10-09T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (556, 27, 5, NULL, CAST(N'2026-10-08T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (557, 27, 6, NULL, CAST(N'2026-10-08T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (558, 27, 7, NULL, CAST(N'2026-10-08T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (559, 27, 5, NULL, CAST(N'2026-10-07T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (560, 27, 6, NULL, CAST(N'2026-10-07T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (561, 27, 7, NULL, CAST(N'2026-10-07T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (562, 27, 5, NULL, CAST(N'2026-10-06T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (563, 27, 6, NULL, CAST(N'2026-10-06T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (564, 27, 7, NULL, CAST(N'2026-10-06T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (565, 27, 5, NULL, CAST(N'2026-10-05T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (566, 27, 6, NULL, CAST(N'2026-10-05T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (567, 27, 7, NULL, CAST(N'2026-10-05T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (568, 27, 5, NULL, CAST(N'2026-10-04T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (569, 27, 6, NULL, CAST(N'2026-10-04T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (570, 27, 7, NULL, CAST(N'2026-10-04T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (571, 27, 5, NULL, CAST(N'2026-10-03T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (572, 27, 6, NULL, CAST(N'2026-10-03T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (573, 27, 7, NULL, CAST(N'2026-10-03T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (574, 27, 5, NULL, CAST(N'2026-10-02T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (575, 27, 6, NULL, CAST(N'2026-10-02T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (576, 27, 7, NULL, CAST(N'2026-10-02T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (577, 27, 5, NULL, CAST(N'2026-10-01T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (578, 27, 6, NULL, CAST(N'2026-10-01T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (579, 27, 7, NULL, CAST(N'2026-10-01T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (580, 27, 5, NULL, CAST(N'2026-09-30T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (581, 27, 6, NULL, CAST(N'2026-09-30T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (582, 27, 7, NULL, CAST(N'2026-09-30T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (583, 27, 5, NULL, CAST(N'2026-09-29T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (584, 27, 6, NULL, CAST(N'2026-09-29T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (585, 27, 7, NULL, CAST(N'2026-09-29T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (586, 27, 5, NULL, CAST(N'2026-09-28T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (587, 27, 6, NULL, CAST(N'2026-09-28T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (588, 27, 7, NULL, CAST(N'2026-09-28T13:41:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (589, 28, 5, NULL, CAST(N'2026-10-11T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (590, 28, 5, NULL, CAST(N'2026-10-10T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (591, 28, 5, NULL, CAST(N'2026-10-09T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (592, 28, 5, NULL, CAST(N'2026-10-08T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (593, 28, 5, NULL, CAST(N'2026-10-07T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (594, 28, 5, NULL, CAST(N'2026-10-06T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (595, 28, 5, NULL, CAST(N'2026-10-05T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (596, 28, 5, NULL, CAST(N'2026-10-04T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (597, 28, 5, NULL, CAST(N'2026-10-03T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (598, 28, 5, NULL, CAST(N'2026-10-02T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (599, 28, 5, NULL, CAST(N'2026-10-01T13:40:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (600, 28, 5, NULL, CAST(N'2026-09-30T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (601, 28, 5, NULL, CAST(N'2026-09-29T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (602, 28, 5, NULL, CAST(N'2026-09-28T13:40:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (603, 29, 5, NULL, CAST(N'2026-10-11T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (604, 29, 6, NULL, CAST(N'2026-10-11T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (605, 29, 5, NULL, CAST(N'2026-10-10T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (606, 29, 6, NULL, CAST(N'2026-10-10T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (607, 29, 5, NULL, CAST(N'2026-10-09T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (608, 29, 6, NULL, CAST(N'2026-10-09T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (609, 29, 5, NULL, CAST(N'2026-10-08T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (610, 29, 6, NULL, CAST(N'2026-10-08T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (611, 29, 5, NULL, CAST(N'2026-10-07T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (612, 29, 6, NULL, CAST(N'2026-10-07T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (613, 29, 5, NULL, CAST(N'2026-10-06T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (614, 29, 6, NULL, CAST(N'2026-10-06T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (615, 29, 5, NULL, CAST(N'2026-10-05T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (616, 29, 6, NULL, CAST(N'2026-10-05T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (617, 29, 5, NULL, CAST(N'2026-10-04T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (618, 29, 6, NULL, CAST(N'2026-10-04T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (619, 29, 5, NULL, CAST(N'2026-10-03T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (620, 29, 6, NULL, CAST(N'2026-10-03T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (621, 29, 5, NULL, CAST(N'2026-10-02T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (622, 29, 6, NULL, CAST(N'2026-10-02T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (623, 29, 5, NULL, CAST(N'2026-10-01T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (624, 29, 6, NULL, CAST(N'2026-10-01T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (625, 29, 5, NULL, CAST(N'2026-09-30T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (626, 29, 6, NULL, CAST(N'2026-09-30T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (627, 29, 5, NULL, CAST(N'2026-09-29T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (628, 29, 6, NULL, CAST(N'2026-09-29T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (629, 29, 5, NULL, CAST(N'2026-09-28T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (630, 29, 6, NULL, CAST(N'2026-09-28T13:39:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (631, 30, 5, NULL, CAST(N'2026-10-11T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (632, 30, 6, NULL, CAST(N'2026-10-11T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (633, 30, 7, NULL, CAST(N'2026-10-11T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (634, 30, 5, NULL, CAST(N'2026-10-10T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (635, 30, 6, NULL, CAST(N'2026-10-10T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (636, 30, 7, NULL, CAST(N'2026-10-10T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (637, 30, 5, NULL, CAST(N'2026-10-09T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (638, 30, 6, NULL, CAST(N'2026-10-09T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (639, 30, 7, NULL, CAST(N'2026-10-09T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (640, 30, 5, NULL, CAST(N'2026-10-08T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (641, 30, 6, NULL, CAST(N'2026-10-08T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (642, 30, 7, NULL, CAST(N'2026-10-08T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (643, 30, 5, NULL, CAST(N'2026-10-07T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (644, 30, 6, NULL, CAST(N'2026-10-07T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (645, 30, 7, NULL, CAST(N'2026-10-07T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (646, 30, 5, NULL, CAST(N'2026-10-06T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (647, 30, 6, NULL, CAST(N'2026-10-06T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (648, 30, 7, NULL, CAST(N'2026-10-06T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (649, 30, 5, NULL, CAST(N'2026-10-05T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (650, 30, 6, NULL, CAST(N'2026-10-05T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (651, 30, 7, NULL, CAST(N'2026-10-05T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (652, 30, 5, NULL, CAST(N'2026-10-04T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (653, 30, 6, NULL, CAST(N'2026-10-04T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (654, 30, 7, NULL, CAST(N'2026-10-04T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (655, 30, 5, NULL, CAST(N'2026-10-03T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (656, 30, 6, NULL, CAST(N'2026-10-03T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (657, 30, 7, NULL, CAST(N'2026-10-03T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (658, 30, 5, NULL, CAST(N'2026-10-02T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (659, 30, 6, NULL, CAST(N'2026-10-02T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (660, 30, 7, NULL, CAST(N'2026-10-02T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (661, 30, 5, NULL, CAST(N'2026-10-01T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (662, 30, 6, NULL, CAST(N'2026-10-01T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (663, 30, 7, NULL, CAST(N'2026-10-01T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (664, 30, 5, NULL, CAST(N'2026-09-30T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (665, 30, 6, NULL, CAST(N'2026-09-30T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (666, 30, 7, NULL, CAST(N'2026-09-30T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (667, 30, 5, NULL, CAST(N'2026-09-29T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (668, 30, 6, NULL, CAST(N'2026-09-29T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (669, 30, 7, NULL, CAST(N'2026-09-29T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (670, 30, 5, NULL, CAST(N'2026-09-28T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (671, 30, 6, NULL, CAST(N'2026-09-28T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (672, 30, 7, NULL, CAST(N'2026-09-28T13:38:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (673, 31, 5, NULL, CAST(N'2026-10-11T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (674, 31, 5, NULL, CAST(N'2026-10-10T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (675, 31, 5, NULL, CAST(N'2026-10-09T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (676, 31, 5, NULL, CAST(N'2026-10-08T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (677, 31, 5, NULL, CAST(N'2026-10-07T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (678, 31, 5, NULL, CAST(N'2026-10-06T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (679, 31, 5, NULL, CAST(N'2026-10-05T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (680, 31, 5, NULL, CAST(N'2026-10-04T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (681, 31, 5, NULL, CAST(N'2026-10-03T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (682, 31, 5, NULL, CAST(N'2026-10-02T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (683, 31, 5, NULL, CAST(N'2026-10-01T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (684, 31, 5, NULL, CAST(N'2026-09-30T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (685, 31, 5, NULL, CAST(N'2026-09-29T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (686, 31, 5, NULL, CAST(N'2026-09-28T13:37:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (687, 32, 5, NULL, CAST(N'2026-10-11T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (688, 32, 6, NULL, CAST(N'2026-10-11T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (689, 32, 5, NULL, CAST(N'2026-10-10T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (690, 32, 6, NULL, CAST(N'2026-10-10T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (691, 32, 5, NULL, CAST(N'2026-10-09T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (692, 32, 6, NULL, CAST(N'2026-10-09T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (693, 32, 5, NULL, CAST(N'2026-10-08T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (694, 32, 6, NULL, CAST(N'2026-10-08T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (695, 32, 5, NULL, CAST(N'2026-10-07T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (696, 32, 6, NULL, CAST(N'2026-10-07T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (697, 32, 5, NULL, CAST(N'2026-10-06T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (698, 32, 6, NULL, CAST(N'2026-10-06T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (699, 32, 5, NULL, CAST(N'2026-10-05T13:36:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (700, 32, 6, NULL, CAST(N'2026-10-05T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (701, 32, 5, NULL, CAST(N'2026-10-04T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (702, 32, 6, NULL, CAST(N'2026-10-04T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (703, 32, 5, NULL, CAST(N'2026-10-03T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (704, 32, 6, NULL, CAST(N'2026-10-03T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (705, 32, 5, NULL, CAST(N'2026-10-02T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (706, 32, 6, NULL, CAST(N'2026-10-02T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (707, 32, 5, NULL, CAST(N'2026-10-01T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (708, 32, 6, NULL, CAST(N'2026-10-01T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (709, 32, 5, NULL, CAST(N'2026-09-30T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (710, 32, 6, NULL, CAST(N'2026-09-30T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (711, 32, 5, NULL, CAST(N'2026-09-29T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (712, 32, 6, NULL, CAST(N'2026-09-29T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (713, 32, 5, NULL, CAST(N'2026-09-28T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (714, 32, 6, NULL, CAST(N'2026-09-28T13:36:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (715, 33, 5, NULL, CAST(N'2026-10-11T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (716, 33, 6, NULL, CAST(N'2026-10-11T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (717, 33, 7, NULL, CAST(N'2026-10-11T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (718, 33, 5, NULL, CAST(N'2026-10-10T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (719, 33, 6, NULL, CAST(N'2026-10-10T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (720, 33, 7, NULL, CAST(N'2026-10-10T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (721, 33, 5, NULL, CAST(N'2026-10-09T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (722, 33, 6, NULL, CAST(N'2026-10-09T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (723, 33, 7, NULL, CAST(N'2026-10-09T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (724, 33, 5, NULL, CAST(N'2026-10-08T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (725, 33, 6, NULL, CAST(N'2026-10-08T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (726, 33, 7, NULL, CAST(N'2026-10-08T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (727, 33, 5, NULL, CAST(N'2026-10-07T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (728, 33, 6, NULL, CAST(N'2026-10-07T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (729, 33, 7, NULL, CAST(N'2026-10-07T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (730, 33, 5, NULL, CAST(N'2026-10-06T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (731, 33, 6, NULL, CAST(N'2026-10-06T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (732, 33, 7, NULL, CAST(N'2026-10-06T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (733, 33, 5, NULL, CAST(N'2026-10-05T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (734, 33, 6, NULL, CAST(N'2026-10-05T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (735, 33, 7, NULL, CAST(N'2026-10-05T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (736, 33, 5, NULL, CAST(N'2026-10-04T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (737, 33, 6, NULL, CAST(N'2026-10-04T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (738, 33, 7, NULL, CAST(N'2026-10-04T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (739, 33, 5, NULL, CAST(N'2026-10-03T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (740, 33, 6, NULL, CAST(N'2026-10-03T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (741, 33, 7, NULL, CAST(N'2026-10-03T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (742, 33, 5, NULL, CAST(N'2026-10-02T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (743, 33, 6, NULL, CAST(N'2026-10-02T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (744, 33, 7, NULL, CAST(N'2026-10-02T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (745, 33, 5, NULL, CAST(N'2026-10-01T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (746, 33, 6, NULL, CAST(N'2026-10-01T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (747, 33, 7, NULL, CAST(N'2026-10-01T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (748, 33, 5, NULL, CAST(N'2026-09-30T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (749, 33, 6, NULL, CAST(N'2026-09-30T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (750, 33, 7, NULL, CAST(N'2026-09-30T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (751, 33, 5, NULL, CAST(N'2026-09-29T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (752, 33, 6, NULL, CAST(N'2026-09-29T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (753, 33, 7, NULL, CAST(N'2026-09-29T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (754, 33, 5, NULL, CAST(N'2026-09-28T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (755, 33, 6, NULL, CAST(N'2026-09-28T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (756, 33, 7, NULL, CAST(N'2026-09-28T13:35:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (757, 37, 5, NULL, CAST(N'2026-10-11T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (758, 37, 5, NULL, CAST(N'2026-10-10T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (759, 37, 5, NULL, CAST(N'2026-10-09T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (760, 37, 5, NULL, CAST(N'2026-10-08T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (761, 37, 5, NULL, CAST(N'2026-10-07T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (762, 37, 5, NULL, CAST(N'2026-10-06T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (763, 37, 5, NULL, CAST(N'2026-10-05T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (764, 37, 5, NULL, CAST(N'2026-10-04T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (765, 37, 5, NULL, CAST(N'2026-10-03T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (766, 37, 5, NULL, CAST(N'2026-10-02T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (767, 37, 5, NULL, CAST(N'2026-10-01T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (768, 37, 5, NULL, CAST(N'2026-09-30T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (769, 37, 5, NULL, CAST(N'2026-09-29T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (770, 37, 5, NULL, CAST(N'2026-09-28T13:31:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (771, 38, 5, NULL, CAST(N'2026-10-11T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (772, 38, 6, NULL, CAST(N'2026-10-11T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (773, 38, 5, NULL, CAST(N'2026-10-10T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (774, 38, 6, NULL, CAST(N'2026-10-10T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (775, 38, 5, NULL, CAST(N'2026-10-09T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (776, 38, 6, NULL, CAST(N'2026-10-09T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (777, 38, 5, NULL, CAST(N'2026-10-08T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (778, 38, 6, NULL, CAST(N'2026-10-08T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (779, 38, 5, NULL, CAST(N'2026-10-07T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (780, 38, 6, NULL, CAST(N'2026-10-07T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (781, 38, 5, NULL, CAST(N'2026-10-06T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (782, 38, 6, NULL, CAST(N'2026-10-06T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (783, 38, 5, NULL, CAST(N'2026-10-05T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (784, 38, 6, NULL, CAST(N'2026-10-05T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (785, 38, 5, NULL, CAST(N'2026-10-04T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (786, 38, 6, NULL, CAST(N'2026-10-04T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (787, 38, 5, NULL, CAST(N'2026-10-03T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (788, 38, 6, NULL, CAST(N'2026-10-03T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (789, 38, 5, NULL, CAST(N'2026-10-02T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (790, 38, 6, NULL, CAST(N'2026-10-02T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (791, 38, 5, NULL, CAST(N'2026-10-01T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (792, 38, 6, NULL, CAST(N'2026-10-01T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (793, 38, 5, NULL, CAST(N'2026-09-30T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (794, 38, 6, NULL, CAST(N'2026-09-30T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (795, 38, 5, NULL, CAST(N'2026-09-29T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (796, 38, 6, NULL, CAST(N'2026-09-29T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (797, 38, 5, NULL, CAST(N'2026-09-28T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (798, 38, 6, NULL, CAST(N'2026-09-28T13:30:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (799, 39, 5, NULL, CAST(N'2026-10-11T13:29:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (800, 39, 6, NULL, CAST(N'2026-10-11T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (801, 39, 7, NULL, CAST(N'2026-10-11T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (802, 39, 5, NULL, CAST(N'2026-10-10T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (803, 39, 6, NULL, CAST(N'2026-10-10T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (804, 39, 7, NULL, CAST(N'2026-10-10T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (805, 39, 5, NULL, CAST(N'2026-10-09T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (806, 39, 6, NULL, CAST(N'2026-10-09T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (807, 39, 7, NULL, CAST(N'2026-10-09T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (808, 39, 5, NULL, CAST(N'2026-10-08T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (809, 39, 6, NULL, CAST(N'2026-10-08T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (810, 39, 7, NULL, CAST(N'2026-10-08T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (811, 39, 5, NULL, CAST(N'2026-10-07T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (812, 39, 6, NULL, CAST(N'2026-10-07T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (813, 39, 7, NULL, CAST(N'2026-10-07T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (814, 39, 5, NULL, CAST(N'2026-10-06T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (815, 39, 6, NULL, CAST(N'2026-10-06T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (816, 39, 7, NULL, CAST(N'2026-10-06T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (817, 39, 5, NULL, CAST(N'2026-10-05T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (818, 39, 6, NULL, CAST(N'2026-10-05T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (819, 39, 7, NULL, CAST(N'2026-10-05T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (820, 39, 5, NULL, CAST(N'2026-10-04T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (821, 39, 6, NULL, CAST(N'2026-10-04T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (822, 39, 7, NULL, CAST(N'2026-10-04T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (823, 39, 5, NULL, CAST(N'2026-10-03T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (824, 39, 6, NULL, CAST(N'2026-10-03T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (825, 39, 7, NULL, CAST(N'2026-10-03T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (826, 39, 5, NULL, CAST(N'2026-10-02T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (827, 39, 6, NULL, CAST(N'2026-10-02T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (828, 39, 7, NULL, CAST(N'2026-10-02T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (829, 39, 5, NULL, CAST(N'2026-10-01T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (830, 39, 6, NULL, CAST(N'2026-10-01T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (831, 39, 7, NULL, CAST(N'2026-10-01T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (832, 39, 5, NULL, CAST(N'2026-09-30T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (833, 39, 6, NULL, CAST(N'2026-09-30T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (834, 39, 7, NULL, CAST(N'2026-09-30T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (835, 39, 5, NULL, CAST(N'2026-09-29T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (836, 39, 6, NULL, CAST(N'2026-09-29T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (837, 39, 7, NULL, CAST(N'2026-09-29T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (838, 39, 5, NULL, CAST(N'2026-09-28T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (839, 39, 6, NULL, CAST(N'2026-09-28T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (840, 39, 7, NULL, CAST(N'2026-09-28T13:29:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (841, 40, 5, NULL, CAST(N'2026-10-11T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (842, 40, 5, NULL, CAST(N'2026-10-10T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (843, 40, 5, NULL, CAST(N'2026-10-09T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (844, 40, 5, NULL, CAST(N'2026-10-08T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (845, 40, 5, NULL, CAST(N'2026-10-07T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (846, 40, 5, NULL, CAST(N'2026-10-06T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (847, 40, 5, NULL, CAST(N'2026-10-05T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (848, 40, 5, NULL, CAST(N'2026-10-04T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (849, 40, 5, NULL, CAST(N'2026-10-03T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (850, 40, 5, NULL, CAST(N'2026-10-02T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (851, 40, 5, NULL, CAST(N'2026-10-01T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (852, 40, 5, NULL, CAST(N'2026-09-30T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (853, 40, 5, NULL, CAST(N'2026-09-29T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (854, 40, 5, NULL, CAST(N'2026-09-28T13:28:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (855, 41, 5, NULL, CAST(N'2026-10-11T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (856, 41, 6, NULL, CAST(N'2026-10-11T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (857, 41, 5, NULL, CAST(N'2026-10-10T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (858, 41, 6, NULL, CAST(N'2026-10-10T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (859, 41, 5, NULL, CAST(N'2026-10-09T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (860, 41, 6, NULL, CAST(N'2026-10-09T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (861, 41, 5, NULL, CAST(N'2026-10-08T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (862, 41, 6, NULL, CAST(N'2026-10-08T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (863, 41, 5, NULL, CAST(N'2026-10-07T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (864, 41, 6, NULL, CAST(N'2026-10-07T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (865, 41, 5, NULL, CAST(N'2026-10-06T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (866, 41, 6, NULL, CAST(N'2026-10-06T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (867, 41, 5, NULL, CAST(N'2026-10-05T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (868, 41, 6, NULL, CAST(N'2026-10-05T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (869, 41, 5, NULL, CAST(N'2026-10-04T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (870, 41, 6, NULL, CAST(N'2026-10-04T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (871, 41, 5, NULL, CAST(N'2026-10-03T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (872, 41, 6, NULL, CAST(N'2026-10-03T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (873, 41, 5, NULL, CAST(N'2026-10-02T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (874, 41, 6, NULL, CAST(N'2026-10-02T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (875, 41, 5, NULL, CAST(N'2026-10-01T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (876, 41, 6, NULL, CAST(N'2026-10-01T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (877, 41, 5, NULL, CAST(N'2026-09-30T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (878, 41, 6, NULL, CAST(N'2026-09-30T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (879, 41, 5, NULL, CAST(N'2026-09-29T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (880, 41, 6, NULL, CAST(N'2026-09-29T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (881, 41, 5, NULL, CAST(N'2026-09-28T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (882, 41, 6, NULL, CAST(N'2026-09-28T13:27:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (883, 42, 5, NULL, CAST(N'2026-10-11T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (884, 42, 6, NULL, CAST(N'2026-10-11T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (885, 42, 7, NULL, CAST(N'2026-10-11T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (886, 42, 5, NULL, CAST(N'2026-10-10T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (887, 42, 6, NULL, CAST(N'2026-10-10T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (888, 42, 7, NULL, CAST(N'2026-10-10T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (889, 42, 5, NULL, CAST(N'2026-10-09T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (890, 42, 6, NULL, CAST(N'2026-10-09T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (891, 42, 7, NULL, CAST(N'2026-10-09T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (892, 42, 5, NULL, CAST(N'2026-10-08T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (893, 42, 6, NULL, CAST(N'2026-10-08T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (894, 42, 7, NULL, CAST(N'2026-10-08T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (895, 42, 5, NULL, CAST(N'2026-10-07T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (896, 42, 6, NULL, CAST(N'2026-10-07T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (897, 42, 7, NULL, CAST(N'2026-10-07T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (898, 42, 5, NULL, CAST(N'2026-10-06T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (899, 42, 6, NULL, CAST(N'2026-10-06T13:26:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (900, 42, 7, NULL, CAST(N'2026-10-06T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (901, 42, 5, NULL, CAST(N'2026-10-05T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (902, 42, 6, NULL, CAST(N'2026-10-05T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (903, 42, 7, NULL, CAST(N'2026-10-05T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (904, 42, 5, NULL, CAST(N'2026-10-04T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (905, 42, 6, NULL, CAST(N'2026-10-04T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (906, 42, 7, NULL, CAST(N'2026-10-04T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (907, 42, 5, NULL, CAST(N'2026-10-03T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (908, 42, 6, NULL, CAST(N'2026-10-03T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (909, 42, 7, NULL, CAST(N'2026-10-03T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (910, 42, 5, NULL, CAST(N'2026-10-02T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (911, 42, 6, NULL, CAST(N'2026-10-02T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (912, 42, 7, NULL, CAST(N'2026-10-02T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (913, 42, 5, NULL, CAST(N'2026-10-01T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (914, 42, 6, NULL, CAST(N'2026-10-01T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (915, 42, 7, NULL, CAST(N'2026-10-01T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (916, 42, 5, NULL, CAST(N'2026-09-30T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (917, 42, 6, NULL, CAST(N'2026-09-30T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (918, 42, 7, NULL, CAST(N'2026-09-30T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (919, 42, 5, NULL, CAST(N'2026-09-29T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (920, 42, 6, NULL, CAST(N'2026-09-29T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (921, 42, 7, NULL, CAST(N'2026-09-29T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (922, 42, 5, NULL, CAST(N'2026-09-28T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (923, 42, 6, NULL, CAST(N'2026-09-28T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (924, 42, 7, NULL, CAST(N'2026-09-28T13:26:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (925, 43, 5, NULL, CAST(N'2026-10-11T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (926, 43, 5, NULL, CAST(N'2026-10-10T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (927, 43, 5, NULL, CAST(N'2026-10-09T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (928, 43, 5, NULL, CAST(N'2026-10-08T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (929, 43, 5, NULL, CAST(N'2026-10-07T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (930, 43, 5, NULL, CAST(N'2026-10-06T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (931, 43, 5, NULL, CAST(N'2026-10-05T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (932, 43, 5, NULL, CAST(N'2026-10-04T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (933, 43, 5, NULL, CAST(N'2026-10-03T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (934, 43, 5, NULL, CAST(N'2026-10-02T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (935, 43, 5, NULL, CAST(N'2026-10-01T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (936, 43, 5, NULL, CAST(N'2026-09-30T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (937, 43, 5, NULL, CAST(N'2026-09-29T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (938, 43, 5, NULL, CAST(N'2026-09-28T13:25:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (939, 44, 5, NULL, CAST(N'2026-10-11T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (940, 44, 6, NULL, CAST(N'2026-10-11T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (941, 44, 5, NULL, CAST(N'2026-10-10T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (942, 44, 6, NULL, CAST(N'2026-10-10T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (943, 44, 5, NULL, CAST(N'2026-10-09T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (944, 44, 6, NULL, CAST(N'2026-10-09T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (945, 44, 5, NULL, CAST(N'2026-10-08T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (946, 44, 6, NULL, CAST(N'2026-10-08T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (947, 44, 5, NULL, CAST(N'2026-10-07T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (948, 44, 6, NULL, CAST(N'2026-10-07T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (949, 44, 5, NULL, CAST(N'2026-10-06T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (950, 44, 6, NULL, CAST(N'2026-10-06T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (951, 44, 5, NULL, CAST(N'2026-10-05T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (952, 44, 6, NULL, CAST(N'2026-10-05T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (953, 44, 5, NULL, CAST(N'2026-10-04T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (954, 44, 6, NULL, CAST(N'2026-10-04T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (955, 44, 5, NULL, CAST(N'2026-10-03T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (956, 44, 6, NULL, CAST(N'2026-10-03T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (957, 44, 5, NULL, CAST(N'2026-10-02T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (958, 44, 6, NULL, CAST(N'2026-10-02T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (959, 44, 5, NULL, CAST(N'2026-10-01T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (960, 44, 6, NULL, CAST(N'2026-10-01T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (961, 44, 5, NULL, CAST(N'2026-09-30T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (962, 44, 6, NULL, CAST(N'2026-09-30T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (963, 44, 5, NULL, CAST(N'2026-09-29T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (964, 44, 6, NULL, CAST(N'2026-09-29T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (965, 44, 5, NULL, CAST(N'2026-09-28T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (966, 44, 6, NULL, CAST(N'2026-09-28T13:24:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (967, 45, 5, NULL, CAST(N'2026-10-11T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (968, 45, 6, NULL, CAST(N'2026-10-11T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (969, 45, 7, NULL, CAST(N'2026-10-11T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (970, 45, 5, NULL, CAST(N'2026-10-10T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (971, 45, 6, NULL, CAST(N'2026-10-10T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (972, 45, 7, NULL, CAST(N'2026-10-10T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (973, 45, 5, NULL, CAST(N'2026-10-09T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (974, 45, 6, NULL, CAST(N'2026-10-09T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (975, 45, 7, NULL, CAST(N'2026-10-09T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (976, 45, 5, NULL, CAST(N'2026-10-08T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (977, 45, 6, NULL, CAST(N'2026-10-08T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (978, 45, 7, NULL, CAST(N'2026-10-08T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (979, 45, 5, NULL, CAST(N'2026-10-07T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (980, 45, 6, NULL, CAST(N'2026-10-07T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (981, 45, 7, NULL, CAST(N'2026-10-07T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (982, 45, 5, NULL, CAST(N'2026-10-06T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (983, 45, 6, NULL, CAST(N'2026-10-06T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (984, 45, 7, NULL, CAST(N'2026-10-06T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (985, 45, 5, NULL, CAST(N'2026-10-05T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (986, 45, 6, NULL, CAST(N'2026-10-05T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (987, 45, 7, NULL, CAST(N'2026-10-05T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (988, 45, 5, NULL, CAST(N'2026-10-04T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (989, 45, 6, NULL, CAST(N'2026-10-04T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (990, 45, 7, NULL, CAST(N'2026-10-04T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (991, 45, 5, NULL, CAST(N'2026-10-03T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (992, 45, 6, NULL, CAST(N'2026-10-03T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (993, 45, 7, NULL, CAST(N'2026-10-03T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (994, 45, 5, NULL, CAST(N'2026-10-02T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (995, 45, 6, NULL, CAST(N'2026-10-02T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (996, 45, 7, NULL, CAST(N'2026-10-02T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (997, 45, 5, NULL, CAST(N'2026-10-01T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (998, 45, 6, NULL, CAST(N'2026-10-01T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (999, 45, 7, NULL, CAST(N'2026-10-01T13:23:15.5400000' AS DateTime2))
GO
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1000, 45, 5, NULL, CAST(N'2026-09-30T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1001, 45, 6, NULL, CAST(N'2026-09-30T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1002, 45, 7, NULL, CAST(N'2026-09-30T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1003, 45, 5, NULL, CAST(N'2026-09-29T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1004, 45, 6, NULL, CAST(N'2026-09-29T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1005, 45, 7, NULL, CAST(N'2026-09-29T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1006, 45, 5, NULL, CAST(N'2026-09-28T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1007, 45, 6, NULL, CAST(N'2026-09-28T13:23:15.5400000' AS DateTime2))
INSERT [dbo].[LuotDocSach] ([MaLuotDoc], [MaSach], [MaTaiKhoan], [MaKhach], [ThoiDiem]) VALUES (1008, 45, 7, NULL, CAST(N'2026-09-28T13:23:15.5400000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[LuotDocSach] OFF
GO
SET IDENTITY_INSERT [dbo].[NoiDungChuong] ON 

INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (1, 1, 1, N'350eae913c995bcf9d1f84b1724a92ca', N'text/plain', N'truyen-01-chuong-01-tep-1.txt', 2263)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (2, 2, 1, N'678d27377a36578fbdb0cc5772f6b53a', N'text/plain', N'truyen-01-chuong-02-tep-1.txt', 2294)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (3, 3, 1, N'c348a35e778951d9930eaa27132afd0b', N'text/plain', N'truyen-01-chuong-03-tep-1.txt', 2266)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (4, 4, 1, N'd1d070e21c9e50b1819ba8e0cad4f51c', N'text/plain', N'truyen-01-chuong-04-tep-1.txt', 2309)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (5, 5, 1, N'db861ce2bd9959339106a6638f41a022', N'text/plain', N'truyen-01-chuong-05-tep-1.txt', 2319)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (6, 6, 1, N'adb6805806815e02a858374eb3dadefd', N'text/plain', N'truyen-01-chuong-06-tep-1.txt', 2306)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (7, 7, 1, N'76f82803c6805f4b9374d1192ae621e8', N'text/plain', N'truyen-02-chuong-01-tep-1.txt', 2271)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (8, 8, 1, N'ffb5d7e7ae9e5f4ca8bc0fc43303590b', N'text/plain', N'truyen-02-chuong-02-tep-1.txt', 2302)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (9, 9, 1, N'e3339841874d537993dbcee495e49907', N'text/plain', N'truyen-02-chuong-03-tep-1.txt', 2274)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (10, 10, 1, N'6177d2ed3ef85879bc461f0459925bfe', N'text/plain', N'truyen-02-chuong-04-tep-1.txt', 2317)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (11, 11, 1, N'24bc89cc8ca0579e95931b3858f60e42', N'text/plain', N'truyen-02-chuong-05-tep-1.txt', 2327)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (12, 12, 1, N'35698f9503df5c31bd22d626c3f6bfe3', N'text/plain', N'truyen-02-chuong-06-tep-1.txt', 2314)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (13, 13, 1, N'c1ac279f77ae5dbab0cbfc11b820f4e6', N'text/plain', N'truyen-03-chuong-01-tep-1.txt', 2289)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (14, 14, 1, N'f46b3b64273d59cca9214411bb6fa4f0', N'text/plain', N'truyen-03-chuong-02-tep-1.txt', 2320)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (15, 15, 1, N'97f9340e95ea575a9f10ad10374de05b', N'text/plain', N'truyen-03-chuong-03-tep-1.txt', 2292)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (16, 16, 1, N'ac85f1943eb8545cb88bd3d6f61225b0', N'text/plain', N'truyen-03-chuong-04-tep-1.txt', 2335)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (17, 17, 1, N'3bed77d5ea105ec085cef1cef71750f7', N'text/plain', N'truyen-03-chuong-05-tep-1.txt', 2345)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (18, 18, 1, N'34bfa7b900c15f9aaf8668fe88447a8d', N'text/plain', N'truyen-03-chuong-06-tep-1.txt', 2332)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (19, 19, 1, N'bf187eb07be559fabdd9e12d7b8ef250', N'text/plain', N'truyen-04-chuong-01-tep-1.txt', 2255)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (20, 20, 1, N'6f3b836fdc3e531094722ce246a8e5fe', N'text/plain', N'truyen-04-chuong-02-tep-1.txt', 2286)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (21, 21, 1, N'14acbdd9d5d35bf0a4cbf0615503793c', N'text/plain', N'truyen-04-chuong-03-tep-1.txt', 2258)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (22, 22, 1, N'5481831c9d8f5cc9b005c8c090bd5f81', N'text/plain', N'truyen-04-chuong-04-tep-1.txt', 2301)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (23, 23, 1, N'70d05fb0999557efb755939fd80f833e', N'text/plain', N'truyen-04-chuong-05-tep-1.txt', 2311)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (24, 24, 1, N'96df23e097a85a80a84bd9071967bcf8', N'text/plain', N'truyen-04-chuong-06-tep-1.txt', 2298)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (25, 25, 1, N'b9c575a5e36f53cc8286546ecf8ecf86', N'text/plain', N'truyen-05-chuong-01-tep-1.txt', 2265)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (26, 26, 1, N'1b82a8b53f0d59d9880bdf944ea9bb38', N'text/plain', N'truyen-05-chuong-02-tep-1.txt', 2296)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (27, 27, 1, N'e2dc996b7de2564092fbd65c13bdf5e0', N'text/plain', N'truyen-05-chuong-03-tep-1.txt', 2268)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (28, 28, 1, N'235883fda5a8597c912c397466aa7bfc', N'text/plain', N'truyen-05-chuong-04-tep-1.txt', 2311)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (29, 29, 1, N'8f6d0bf6f8d452eda49f12f965b42575', N'text/plain', N'truyen-05-chuong-05-tep-1.txt', 2321)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (30, 30, 1, N'88e0e5da19ee5cc48ccc9e06ba8bee5b', N'text/plain', N'truyen-05-chuong-06-tep-1.txt', 2308)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (31, 31, 1, N'7ff480fca6055d669a01364ac242d31b', N'text/plain', N'truyen-06-chuong-01-tep-1.txt', 2281)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (32, 32, 1, N'dbc3e1c96e775d588908aee4e1ccacd2', N'text/plain', N'truyen-06-chuong-02-tep-1.txt', 2312)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (33, 33, 1, N'67fcfc9f02fb579ba8e666160389ea5a', N'text/plain', N'truyen-06-chuong-03-tep-1.txt', 2284)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (34, 34, 1, N'954ee4d5d585563d9b82c04ffac4a980', N'text/plain', N'truyen-06-chuong-04-tep-1.txt', 2327)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (35, 35, 1, N'e3b4729486955c558a1c184ad0461c59', N'text/plain', N'truyen-06-chuong-05-tep-1.txt', 2337)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (36, 36, 1, N'58b30e76a7eb5ab1bf21aeeaceab7e19', N'text/plain', N'truyen-06-chuong-06-tep-1.txt', 2324)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (37, 37, 1, N'57e4ab8c57b653c78ef6a745604b5794', N'text/plain', N'truyen-07-chuong-01-tep-1.txt', 2289)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (38, 38, 1, N'f51ac3ab2df55e919e752ded51b34680', N'text/plain', N'truyen-07-chuong-02-tep-1.txt', 2320)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (39, 39, 1, N'bbc92ae019715ba6a224192257457341', N'text/plain', N'truyen-07-chuong-03-tep-1.txt', 2292)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (40, 40, 1, N'55af10bb0da95ce19f3e3f9d0bdf3ddc', N'text/plain', N'truyen-07-chuong-04-tep-1.txt', 2335)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (41, 41, 1, N'ee3640425f4c5d2798907aff5555b496', N'text/plain', N'truyen-07-chuong-05-tep-1.txt', 2345)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (42, 42, 1, N'9638ed8ba086515fa7dba63f5edeeb8f', N'text/plain', N'truyen-07-chuong-06-tep-1.txt', 2332)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (43, 43, 1, N'fc6b1f0f80b15262a692d4c85e7a5431', N'text/plain', N'truyen-08-chuong-01-tep-1.txt', 2291)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (44, 44, 1, N'02180cc1bf0754a8b7bbd400e4ff0536', N'text/plain', N'truyen-08-chuong-02-tep-1.txt', 2322)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (45, 45, 1, N'4ec40b3f2e9e580baa6cecf32440f7b2', N'text/plain', N'truyen-08-chuong-03-tep-1.txt', 2294)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (46, 46, 1, N'700b8de22bea5489a079b3747b3ec82a', N'text/plain', N'truyen-08-chuong-04-tep-1.txt', 2337)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (47, 47, 1, N'7e5b741f07b65ceaaacad3943941c5b7', N'text/plain', N'truyen-08-chuong-05-tep-1.txt', 2347)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (48, 48, 1, N'6dbdcce169ea5f3d81326b381ea58212', N'text/plain', N'truyen-08-chuong-06-tep-1.txt', 2334)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (49, 49, 1, N'65e2c6c6b4ab57b8a988337e6ebd7108', N'text/plain', N'truyen-09-chuong-01-tep-1.txt', 2259)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (50, 50, 1, N'e3c2f8f17131540d9387ca7b0059d715', N'text/plain', N'truyen-09-chuong-02-tep-1.txt', 2290)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (51, 51, 1, N'a0993921c1ba5368bb5962d2232e7754', N'text/plain', N'truyen-09-chuong-03-tep-1.txt', 2262)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (52, 52, 1, N'79f9e09256a65715b08d7c5505c4dc6e', N'text/plain', N'truyen-09-chuong-04-tep-1.txt', 2305)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (53, 53, 1, N'0b8223587fbe51ec99b0eab809fb5213', N'text/plain', N'truyen-09-chuong-05-tep-1.txt', 2315)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (54, 54, 1, N'2701b6c92fb05ea6aecba5f49ab4f99c', N'text/plain', N'truyen-09-chuong-06-tep-1.txt', 2302)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (55, 55, 1, N'044a7d5bffcb5f938b3ff53d90b20405', N'text/plain', N'truyen-10-chuong-01-tep-1.txt', 2283)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (56, 56, 1, N'224ea644752c52528ac8612f420571b4', N'text/plain', N'truyen-10-chuong-02-tep-1.txt', 2314)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (57, 57, 1, N'90a5fc3f573a539e948ec30bd045c74f', N'text/plain', N'truyen-10-chuong-03-tep-1.txt', 2286)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (58, 58, 1, N'24a669e3dfff5929ac6d5b6edb2751e7', N'text/plain', N'truyen-10-chuong-04-tep-1.txt', 2329)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (59, 59, 1, N'9829323589b4562d95a7ae27f8d6a805', N'text/plain', N'truyen-10-chuong-05-tep-1.txt', 2339)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (60, 60, 1, N'896389f8a308582dba47ef6e78f0ff4b', N'text/plain', N'truyen-10-chuong-06-tep-1.txt', 2326)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (61, 61, 1, N'0e3ad1a2ad705156ac5706bd693d385f', N'text/plain', N'truyen-11-chuong-01-tep-1.txt', 2269)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (62, 62, 1, N'5af06a59ea7a5adb9b5f7b751234d6a2', N'text/plain', N'truyen-11-chuong-02-tep-1.txt', 2300)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (63, 63, 1, N'9f33d2c15d3c58268358bf74584add63', N'text/plain', N'truyen-11-chuong-03-tep-1.txt', 2272)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (64, 64, 1, N'140af1d15aca53b78e3c48f0d7431475', N'text/plain', N'truyen-11-chuong-04-tep-1.txt', 2315)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (65, 65, 1, N'e65ac5c91c2f54f2a263527a711eeea3', N'text/plain', N'truyen-11-chuong-05-tep-1.txt', 2325)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (66, 66, 1, N'24f988aabf525552bf4a7c01e763e0c3', N'text/plain', N'truyen-11-chuong-06-tep-1.txt', 2312)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (67, 67, 1, N'df23273970005262b4b56b7870301cae', N'text/plain', N'truyen-12-chuong-01-tep-1.txt', 2253)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (68, 68, 1, N'db1a6fe981d9553fb5d62ee213452598', N'text/plain', N'truyen-12-chuong-02-tep-1.txt', 2284)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (69, 69, 1, N'8b218a6317605122a2e19d7854a7e06a', N'text/plain', N'truyen-12-chuong-03-tep-1.txt', 2256)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (70, 70, 1, N'55bd1617aa3d5ecebc98c2e266c4dd42', N'text/plain', N'truyen-12-chuong-04-tep-1.txt', 2299)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (71, 71, 1, N'd965107cf70853ce87445e6c5ada4902', N'text/plain', N'truyen-12-chuong-05-tep-1.txt', 2309)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (72, 72, 1, N'ba5f879967f95ad4a7877f2e41a3c86a', N'text/plain', N'truyen-12-chuong-06-tep-1.txt', 2296)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (73, 73, 1, N'34ec8437f6bd5f168a02eb4823329e80', N'text/plain', N'truyen-13-chuong-01-tep-1.txt', 2289)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (74, 74, 1, N'fb1002a054cb5b99961d48343ae8d98a', N'text/plain', N'truyen-13-chuong-02-tep-1.txt', 2320)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (75, 75, 1, N'ed076da45e7d516a9ae65a0e7bde630e', N'text/plain', N'truyen-13-chuong-03-tep-1.txt', 2292)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (76, 76, 1, N'93bd0dc10c115184be3d5be545a8263c', N'text/plain', N'truyen-13-chuong-04-tep-1.txt', 2335)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (77, 77, 1, N'98602e1c030252adac6465371968aa42', N'text/plain', N'truyen-13-chuong-05-tep-1.txt', 2345)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (78, 78, 1, N'83ec098dcf0a556a935d60548f1c0191', N'text/plain', N'truyen-13-chuong-06-tep-1.txt', 2332)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (79, 79, 1, N'610baeb3b66f50cda1162173c9829000', N'text/plain', N'truyen-14-chuong-01-tep-1.txt', 2285)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (80, 80, 1, N'e567f8e9e90d5dd0821d386ea1e83e87', N'text/plain', N'truyen-14-chuong-02-tep-1.txt', 2316)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (81, 81, 1, N'f1115dfa9edb50648cf87d8551d442ed', N'text/plain', N'truyen-14-chuong-03-tep-1.txt', 2288)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (82, 82, 1, N'531bb3d9d49650ea91caf4b85fc61a92', N'text/plain', N'truyen-14-chuong-04-tep-1.txt', 2331)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (83, 83, 1, N'12ddc83c2d4257d4b5591524be00c367', N'text/plain', N'truyen-14-chuong-05-tep-1.txt', 2341)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (84, 84, 1, N'f325458097e8564395f9256c228b612c', N'text/plain', N'truyen-14-chuong-06-tep-1.txt', 2328)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (85, 85, 1, N'b933303bf5f553b9af5174d3de6fdcfc', N'text/plain', N'truyen-15-chuong-01-tep-1.txt', 2275)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (86, 86, 1, N'fafd662500085d4bbde5a40d3dd5dbd9', N'text/plain', N'truyen-15-chuong-02-tep-1.txt', 2306)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (87, 87, 1, N'5b32f362dad559b6bbffee5b0895cdc1', N'text/plain', N'truyen-15-chuong-03-tep-1.txt', 2278)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (88, 88, 1, N'7bd37ecd5adc505694c59e0f0115db04', N'text/plain', N'truyen-15-chuong-04-tep-1.txt', 2321)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (89, 89, 1, N'cacba80625d85af886362ea19225346e', N'text/plain', N'truyen-15-chuong-05-tep-1.txt', 2331)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (90, 90, 1, N'c82a9d87024c5269ab98981a5725cfae', N'text/plain', N'truyen-15-chuong-06-tep-1.txt', 2318)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (91, 91, 1, N'359feeebd8ea59adaf8e6f5a7548bfcf', N'text/plain', N'truyen-16-chuong-01-tep-1.txt', 2281)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (92, 92, 1, N'12f12676184559b9911469147fdda1a2', N'text/plain', N'truyen-16-chuong-02-tep-1.txt', 2312)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (93, 93, 1, N'5499e517f63c552ba7c62a600b9c7715', N'text/plain', N'truyen-16-chuong-03-tep-1.txt', 2284)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (94, 94, 1, N'2c2f7be0f17f52dbb7380930c4b9bfe3', N'text/plain', N'truyen-16-chuong-04-tep-1.txt', 2327)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (95, 95, 1, N'7f611c568ade54abaad307422b6e88ef', N'text/plain', N'truyen-16-chuong-05-tep-1.txt', 2337)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (96, 96, 1, N'0c9fc03b2f03504d870d268a1ec0cdbe', N'text/plain', N'truyen-16-chuong-06-tep-1.txt', 2324)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (97, 97, 1, N'1855f764375057a79289689d9b198899', N'text/plain', N'truyen-17-chuong-01-tep-1.txt', 2277)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (98, 98, 1, N'4f25244264795b37896e5a2d4d1bcf06', N'text/plain', N'truyen-17-chuong-02-tep-1.txt', 2308)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (99, 99, 1, N'9c70edbaaec453acb1acc9c4a48b7370', N'text/plain', N'truyen-17-chuong-03-tep-1.txt', 2280)
GO
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (100, 100, 1, N'09b151c367015362ae4f2fb1fdf15e9b', N'text/plain', N'truyen-17-chuong-04-tep-1.txt', 2323)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (101, 101, 1, N'df2e46f1ad275822b4d8bd63c382a5de', N'text/plain', N'truyen-17-chuong-05-tep-1.txt', 2333)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (102, 102, 1, N'444b85a08d0a59da91c4b357fbe7c74c', N'text/plain', N'truyen-17-chuong-06-tep-1.txt', 2320)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (103, 103, 1, N'79b15b4ebd2a5e56a8547b229d961004', N'text/plain', N'truyen-18-chuong-01-tep-1.txt', 2267)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (104, 104, 1, N'efcdcb1feb9c5531b105d8ce38394faf', N'text/plain', N'truyen-18-chuong-02-tep-1.txt', 2298)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (105, 105, 1, N'a484775e22815582bf76469fdf309bde', N'text/plain', N'truyen-18-chuong-03-tep-1.txt', 2270)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (106, 106, 1, N'6dab1a3e6c3b579594eb0f512f5de5ca', N'text/plain', N'truyen-18-chuong-04-tep-1.txt', 2313)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (107, 107, 1, N'754ce11b19bc5c80b0ff4c6d7e7e61ed', N'text/plain', N'truyen-18-chuong-05-tep-1.txt', 2323)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (108, 108, 1, N'819c98ae26ee5d478b2d07ef3e772f55', N'text/plain', N'truyen-18-chuong-06-tep-1.txt', 2310)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (109, 109, 1, N'1a3b2d8d472c59c48151baf997243c71', N'text/plain', N'truyen-19-chuong-01-tep-1.txt', 2283)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (110, 110, 1, N'c91815966d8c52b8a8b13eed339335ce', N'text/plain', N'truyen-19-chuong-02-tep-1.txt', 2314)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (111, 111, 1, N'4529563d521d5ad38ae5a19186ca95f5', N'text/plain', N'truyen-19-chuong-03-tep-1.txt', 2286)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (112, 112, 1, N'35ca3660cce9510a8ed0c58ed5b5084a', N'text/plain', N'truyen-19-chuong-04-tep-1.txt', 2329)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (113, 113, 1, N'7551d7f65618540fb7c8ab25b99e1910', N'text/plain', N'truyen-19-chuong-05-tep-1.txt', 2339)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (114, 114, 1, N'2975f0849c4c536fbdea24a7f941c78d', N'text/plain', N'truyen-19-chuong-06-tep-1.txt', 2326)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (115, 115, 1, N'581105844429543dbbc961ae7b8a0e57', N'text/plain', N'truyen-20-chuong-01-tep-1.txt', 2269)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (116, 116, 1, N'00ff1a4018705857af13f737faf32d41', N'text/plain', N'truyen-20-chuong-02-tep-1.txt', 2300)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (117, 117, 1, N'97f98cd013c55423a307cb9bdfa60951', N'text/plain', N'truyen-20-chuong-03-tep-1.txt', 2272)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (118, 118, 1, N'35e64b4f88a658718b3e6060d777daad', N'text/plain', N'truyen-20-chuong-04-tep-1.txt', 2315)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (119, 119, 1, N'e7cdffd1672856c28a97418098e284f8', N'text/plain', N'truyen-20-chuong-05-tep-1.txt', 2325)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (120, 120, 1, N'0b82f8bc352f5b6486ca5cdcdb94eca4', N'text/plain', N'truyen-20-chuong-06-tep-1.txt', 2312)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (121, 121, 1, N'227fa7eedce25cd7ad419c94cf86bdd7', N'text/plain', N'truyen-21-chuong-01-tep-1.txt', 2275)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (122, 122, 1, N'e43eeb1958ab5f32bab7c8f92315e4c6', N'text/plain', N'truyen-21-chuong-02-tep-1.txt', 2306)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (123, 123, 1, N'8d25ee74c49152aeae0922e6df7d5024', N'text/plain', N'truyen-21-chuong-03-tep-1.txt', 2278)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (124, 124, 1, N'19f44210b4705578b80249ecf52d5fd1', N'text/plain', N'truyen-21-chuong-04-tep-1.txt', 2321)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (125, 125, 1, N'4d246b941a615bcfa078c2fea2d7536d', N'text/plain', N'truyen-21-chuong-05-tep-1.txt', 2331)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (126, 126, 1, N'b32d9f6e390358419b995b2c1af16572', N'text/plain', N'truyen-21-chuong-06-tep-1.txt', 2318)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (127, 127, 1, N'f8c1e965579b508f825aa2e1beba902f', N'text/plain', N'truyen-22-chuong-01-tep-1.txt', 2285)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (128, 128, 1, N'c22950644c1852b88eb4d9a063cfdb83', N'text/plain', N'truyen-22-chuong-02-tep-1.txt', 2316)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (129, 129, 1, N'7108060d51435f2598d348d9a7620a49', N'text/plain', N'truyen-22-chuong-03-tep-1.txt', 2288)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (130, 130, 1, N'20479e576d4657d6948a8a315f99c617', N'text/plain', N'truyen-22-chuong-04-tep-1.txt', 2331)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (131, 131, 1, N'4b85ef4d963354f29ea45be0be893c5d', N'text/plain', N'truyen-22-chuong-05-tep-1.txt', 2341)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (132, 132, 1, N'ecdab7af49bc57daa0af8898122c81d5', N'text/plain', N'truyen-22-chuong-06-tep-1.txt', 2328)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (133, 133, 1, N'2e22aadf35965937a3825460c8d447f6', N'text/plain', N'truyen-23-chuong-01-tep-1.txt', 2277)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (134, 134, 1, N'53f5702bc186538dae94a48e37bc3caa', N'text/plain', N'truyen-23-chuong-02-tep-1.txt', 2308)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (135, 135, 1, N'cafe171617eb53f6934ce0280edc37ca', N'text/plain', N'truyen-23-chuong-03-tep-1.txt', 2280)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (136, 136, 1, N'865151625e0d526a99af3d42b88aeb09', N'text/plain', N'truyen-23-chuong-04-tep-1.txt', 2323)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (137, 137, 1, N'c52b5bb2d6e35cc0a2df366396dfad39', N'text/plain', N'truyen-23-chuong-05-tep-1.txt', 2333)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (138, 138, 1, N'f2531cb0dd86575592d98e51220faef9', N'text/plain', N'truyen-23-chuong-06-tep-1.txt', 2320)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (139, 139, 1, N'd7f0325c1106580bba0d7944ca83dbaf', N'text/plain', N'truyen-24-chuong-01-tep-1.txt', 2281)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (140, 140, 1, N'6524efe3646b5c2fb1081a3007c4a5ad', N'text/plain', N'truyen-24-chuong-02-tep-1.txt', 2312)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (141, 141, 1, N'639f227897175cce84b4b417f65b6603', N'text/plain', N'truyen-24-chuong-03-tep-1.txt', 2284)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (142, 142, 1, N'0913b4219ee35fd9a5e7c37fe2929ccb', N'text/plain', N'truyen-24-chuong-04-tep-1.txt', 2327)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (143, 143, 1, N'fafaf04ccadc5b44b96e58c328a3c892', N'text/plain', N'truyen-24-chuong-05-tep-1.txt', 2337)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (144, 144, 1, N'269416e03a785288adcfe6bcfeaa622d', N'text/plain', N'truyen-24-chuong-06-tep-1.txt', 2324)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (145, 145, 1, N'b7bf45f324ab51cb825bd08cd75b6109', N'text/plain', N'truyen-25-chuong-01-tep-1.txt', 2253)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (146, 146, 1, N'd583885ce7d65f4cb0a7c7d7c0ba702a', N'text/plain', N'truyen-25-chuong-02-tep-1.txt', 2284)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (147, 147, 1, N'bf825ccaff7b5f1c82f9517e25ff06a0', N'text/plain', N'truyen-25-chuong-03-tep-1.txt', 2256)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (148, 148, 1, N'feffb1aa8d3e585fac53832bb0f5e2f2', N'text/plain', N'truyen-25-chuong-04-tep-1.txt', 2299)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (149, 149, 1, N'b9408b0e816b59e4b1842d4f6b050544', N'text/plain', N'truyen-25-chuong-05-tep-1.txt', 2309)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (150, 150, 1, N'040be4f71c0b5dc0a28994227beab40d', N'text/plain', N'truyen-25-chuong-06-tep-1.txt', 2296)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (151, 151, 1, N'fd1c9bec3566556e87021f5a3f2eb218', N'text/plain', N'truyen-26-chuong-01-tep-1.txt', 2281)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (152, 152, 1, N'2abb65792768520f9d5e33af36741ccc', N'text/plain', N'truyen-26-chuong-02-tep-1.txt', 2312)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (153, 153, 1, N'd7bc5701d08e548e852dae0adcdf4a8d', N'text/plain', N'truyen-26-chuong-03-tep-1.txt', 2284)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (154, 154, 1, N'6718c1c946135629b295fa00c7474b87', N'text/plain', N'truyen-26-chuong-04-tep-1.txt', 2327)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (155, 155, 1, N'089993f8822b56c98c49530a7075f623', N'text/plain', N'truyen-26-chuong-05-tep-1.txt', 2337)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (156, 156, 1, N'be41bc821fda58c9809660c8bd60922b', N'text/plain', N'truyen-26-chuong-06-tep-1.txt', 2324)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (157, 157, 1, N'9c01d10608d357e58bbcd31fc17ca2bc', N'text/plain', N'truyen-27-chuong-01-tep-1.txt', 2273)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (158, 158, 1, N'bd2deea6eff05c49be58364b7379f3d7', N'text/plain', N'truyen-27-chuong-02-tep-1.txt', 2304)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (159, 159, 1, N'85f2e9f174625fa088c8d4db4b3d82fd', N'text/plain', N'truyen-27-chuong-03-tep-1.txt', 2276)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (160, 160, 1, N'2ccf4a69518f5e2ab39c64b60be0b80f', N'text/plain', N'truyen-27-chuong-04-tep-1.txt', 2319)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (161, 161, 1, N'7328f15e8705582888baa73383116284', N'text/plain', N'truyen-27-chuong-05-tep-1.txt', 2329)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (162, 162, 1, N'463f5338e24e5a518298b5de3c9f0a25', N'text/plain', N'truyen-27-chuong-06-tep-1.txt', 2316)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (163, 163, 1, N'3bdb08af4671541f83130ee69a15f5a7', N'text/plain', N'truyen-28-chuong-01-tep-1.txt', 2245)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (164, 164, 1, N'0213d1c2088e5307bca76d72e5301619', N'text/plain', N'truyen-28-chuong-02-tep-1.txt', 2276)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (165, 165, 1, N'558bfcf148d4530ba4a1014e65fd0f53', N'text/plain', N'truyen-28-chuong-03-tep-1.txt', 2248)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (166, 166, 1, N'feea45eb2b655e0da6ab38c17b2a344d', N'text/plain', N'truyen-28-chuong-04-tep-1.txt', 2291)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (167, 167, 1, N'cbf062a1766a59d5845e892703c0a835', N'text/plain', N'truyen-28-chuong-05-tep-1.txt', 2301)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (168, 168, 1, N'e65b8402761a5ce88dcc2ae36f9cdcc6', N'text/plain', N'truyen-28-chuong-06-tep-1.txt', 2288)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (169, 169, 1, N'c33465a3188d5e05b477f774eca8333c', N'text/markdown', N'truyen-29-chuong-01-tep-1.md', 2284)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (170, 170, 1, N'02f8b973845157f497f0a043fc78a2da', N'text/markdown', N'truyen-29-chuong-02-tep-1.md', 2315)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (171, 171, 1, N'b68398e585715ffd922b0e19410449c3', N'text/markdown', N'truyen-29-chuong-03-tep-1.md', 2287)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (172, 172, 1, N'3e9934e9ea9c5b46b40bda35ca36887c', N'text/markdown', N'truyen-29-chuong-04-tep-1.md', 2330)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (173, 173, 1, N'3209c7f0f08c5fc587aa9e07e5a2cf95', N'text/markdown', N'truyen-29-chuong-05-tep-1.md', 2340)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (174, 174, 1, N'd2cf856a0b185bb5939dc6a343f88647', N'text/markdown', N'truyen-29-chuong-06-tep-1.md', 2327)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (175, 175, 1, N'71deae87da9456a798072266db26f480', N'text/markdown', N'truyen-30-chuong-01-tep-1.md', 2286)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (176, 176, 1, N'7ee377f25325503886cdb0594acc00a1', N'text/markdown', N'truyen-30-chuong-02-tep-1.md', 2317)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (177, 177, 1, N'f3f8f10e8c585442943fa87578b21428', N'text/markdown', N'truyen-30-chuong-03-tep-1.md', 2289)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (178, 178, 1, N'7d44cfde349d5ed086febeffd25c06ec', N'text/markdown', N'truyen-30-chuong-04-tep-1.md', 2332)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (179, 179, 1, N'7d47ca52d10b5e81960624b33ac03b6d', N'text/markdown', N'truyen-30-chuong-05-tep-1.md', 2342)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (180, 180, 1, N'ddd704132c3d5716993a31e73946c4ff', N'text/markdown', N'truyen-30-chuong-06-tep-1.md', 2329)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (181, 181, 1, N'49509fc305815c83b43bb63e4f549482', N'text/markdown', N'truyen-31-chuong-01-tep-1.md', 2288)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (182, 182, 1, N'acf3801e033057bebe8ac53a43c2b931', N'text/markdown', N'truyen-31-chuong-02-tep-1.md', 2319)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (183, 183, 1, N'702f8a26de5c507e90a214630e5c0d98', N'text/markdown', N'truyen-31-chuong-03-tep-1.md', 2291)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (184, 184, 1, N'e51b73945d9c5d1b8274c13dd1fc887c', N'text/markdown', N'truyen-31-chuong-04-tep-1.md', 2334)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (185, 185, 1, N'bbc5a86eccf858d888193c97f65466e3', N'text/markdown', N'truyen-31-chuong-05-tep-1.md', 2344)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (186, 186, 1, N'60e07c618b51559e9674c21155b3667b', N'text/markdown', N'truyen-31-chuong-06-tep-1.md', 2331)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (187, 187, 1, N'ce86db316c495f17a2de71f6b41c0637', N'text/markdown', N'truyen-32-chuong-01-tep-1.md', 2312)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (188, 188, 1, N'6805af508391540f922d6ec8d89ec257', N'text/markdown', N'truyen-32-chuong-02-tep-1.md', 2343)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (189, 189, 1, N'44e44a254f705d23bf82f7c84d7c3107', N'text/markdown', N'truyen-32-chuong-03-tep-1.md', 2315)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (190, 190, 1, N'ee82c29ccd59545b8854a58097a54fe0', N'text/markdown', N'truyen-32-chuong-04-tep-1.md', 2358)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (191, 191, 1, N'89021ba9fb0f5838bbe131bbfbcf687a', N'text/markdown', N'truyen-32-chuong-05-tep-1.md', 2368)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (192, 192, 1, N'55d00468b1e657e6942799b75bcb7174', N'text/markdown', N'truyen-32-chuong-06-tep-1.md', 2355)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (193, 193, 1, N'62e5bec888c554b7bf8caf206c161a6f', N'application/pdf', N'truyen-33-chuong-01-tep-1.pdf', 49032)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (194, 194, 1, N'6ef7634886915b45b1d77073565436b7', N'application/pdf', N'truyen-33-chuong-02-tep-1.pdf', 49022)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (195, 195, 1, N'c93b22c59cf6515bbb0de0a01b959a93', N'application/pdf', N'truyen-33-chuong-03-tep-1.pdf', 48968)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (196, 196, 1, N'fedf4843a348589eb038c492f053399a', N'application/pdf', N'truyen-33-chuong-04-tep-1.pdf', 48946)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (197, 197, 1, N'30da23b707815439a56d48bfbbc89351', N'application/pdf', N'truyen-33-chuong-05-tep-1.pdf', 49007)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (198, 198, 1, N'48bc0a46746a5eaab37e75d67010ae25', N'application/pdf', N'truyen-33-chuong-06-tep-1.pdf', 49082)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (199, 199, 1, N'c94f4208148d50b188e4682b83f03271', N'application/pdf', N'truyen-34-chuong-01-tep-1.pdf', 48691)
GO
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (200, 200, 1, N'e548519693c9547abe00dfd62159e479', N'application/pdf', N'truyen-34-chuong-02-tep-1.pdf', 48529)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (201, 201, 1, N'110956afa8075aa18f83b0e9fd1d6da9', N'application/pdf', N'truyen-34-chuong-03-tep-1.pdf', 48622)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (202, 202, 1, N'6ecfe4907d23574cb4823691e6476b87', N'application/pdf', N'truyen-34-chuong-04-tep-1.pdf', 48985)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (203, 203, 1, N'b9a7b4359876507286d69edcf15d533c', N'application/pdf', N'truyen-34-chuong-05-tep-1.pdf', 48751)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (204, 204, 1, N'cc9a3bfe0c4e50799094d977ab417b0e', N'application/pdf', N'truyen-34-chuong-06-tep-1.pdf', 48822)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (205, 205, 1, N'17394ee94a0e5fbcaa633f8489d41608', N'application/pdf', N'truyen-35-chuong-01-tep-1.pdf', 48989)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (206, 206, 1, N'1a76e873bf385f459c77243776efd184', N'application/pdf', N'truyen-35-chuong-02-tep-1.pdf', 48981)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (207, 207, 1, N'c23c05d13faf556f8e38453cc1f760ea', N'application/pdf', N'truyen-35-chuong-03-tep-1.pdf', 48895)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (208, 208, 1, N'3a5618f11fa358cc8c67ee50f86c9f7a', N'application/pdf', N'truyen-35-chuong-04-tep-1.pdf', 48892)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (209, 209, 1, N'a0e442cf295a50ed82247dfe06a2db1d', N'application/pdf', N'truyen-35-chuong-05-tep-1.pdf', 49087)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (210, 210, 1, N'11077aff7cd85327be5d74af5cd84a8b', N'application/pdf', N'truyen-35-chuong-06-tep-1.pdf', 49057)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (211, 211, 1, N'631973fad3a052bfaf478d2b58708639', N'application/pdf', N'truyen-36-chuong-01-tep-1.pdf', 48695)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (212, 212, 1, N'b9f60f0852e95f6b8b4d583838c9f2ac', N'application/pdf', N'truyen-36-chuong-02-tep-1.pdf', 48452)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (213, 213, 1, N'f08fbb46098a5b09b80ea60609c3fbfe', N'application/pdf', N'truyen-36-chuong-03-tep-1.pdf', 48495)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (214, 214, 1, N'5c598b37ac0a5c5d8180f513771c03c7', N'application/pdf', N'truyen-36-chuong-04-tep-1.pdf', 48874)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (215, 215, 1, N'e46218629caa5740817e2494c9be3bde', N'application/pdf', N'truyen-36-chuong-05-tep-1.pdf', 48654)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (216, 216, 1, N'21ea899c2dcb5fe7ab9f8575595e9b4a', N'application/pdf', N'truyen-36-chuong-06-tep-1.pdf', 48780)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (217, 217, 1, N'b06b9c6af63f59a682c87be50787a8a4', N'image/png', N'truyen-37-chuong-01-tep-1.png', 35615)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (218, 217, 2, N'fb11b896a3cf55a18acba28700a44a76', N'image/png', N'truyen-37-chuong-01-tep-2.png', 34665)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (219, 217, 3, N'299d0ca13dbd54c9971be59748bb6050', N'image/png', N'truyen-37-chuong-01-tep-3.png', 35315)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (220, 218, 1, N'6429dd1c8058577fbf2de03349d80070', N'image/png', N'truyen-37-chuong-02-tep-1.png', 36651)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (221, 218, 2, N'f8188f66fbeb50fc82ab321a28a953ae', N'image/png', N'truyen-37-chuong-02-tep-2.png', 34862)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (222, 218, 3, N'4f63864c5cfd5829b0fb499d4bd15d1a', N'image/png', N'truyen-37-chuong-02-tep-3.png', 36178)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (223, 219, 1, N'00e6c964e9ee5b9db98114ed2c14647f', N'image/png', N'truyen-37-chuong-03-tep-1.png', 36761)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (224, 219, 2, N'145648bb5aaf5b5e919916310579727e', N'image/png', N'truyen-37-chuong-03-tep-2.png', 35609)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (225, 219, 3, N'f4d94be812935bdf8d4cc197407e1d4e', N'image/png', N'truyen-37-chuong-03-tep-3.png', 35790)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (226, 220, 1, N'85f9cd4043395321bb763abcd058cfa2', N'image/png', N'truyen-37-chuong-04-tep-1.png', 36267)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (227, 220, 2, N'1d98989fdd405677bd37b5b670ae8f27', N'image/png', N'truyen-37-chuong-04-tep-2.png', 35113)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (228, 220, 3, N'70f6f288ae215a11b19fe8ea71d2b2df', N'image/png', N'truyen-37-chuong-04-tep-3.png', 35773)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (229, 221, 1, N'949a0d87f77c5fc5a750eb5eedd9b981', N'image/png', N'truyen-37-chuong-05-tep-1.png', 36288)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (230, 221, 2, N'8420332d7c035d66a58f360bf8aec2b8', N'image/png', N'truyen-37-chuong-05-tep-2.png', 35130)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (231, 221, 3, N'8807ba32019158ad856ec13b25661611', N'image/png', N'truyen-37-chuong-05-tep-3.png', 35805)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (232, 222, 1, N'b9896e5afd0f53bda94a2a4a2d29e5ae', N'image/png', N'truyen-37-chuong-06-tep-1.png', 37411)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (233, 222, 2, N'c533f03c2e05584cae516c9ea84d06cd', N'image/png', N'truyen-37-chuong-06-tep-2.png', 36246)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (234, 222, 3, N'f3b25e8fefc55cb5823003b7b63658e6', N'image/png', N'truyen-37-chuong-06-tep-3.png', 36937)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (235, 223, 1, N'65fdd7659d1455c8a624a60cda99316b', N'image/png', N'truyen-38-chuong-01-tep-1.png', 36489)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (236, 223, 2, N'c1b42f489596503a9a56bf145c5fb679', N'image/png', N'truyen-38-chuong-01-tep-2.png', 35551)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (237, 223, 3, N'5b4b00b32b1d595bba2c1896a2097254', N'image/png', N'truyen-38-chuong-01-tep-3.png', 36243)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (238, 224, 1, N'20e42ab614be55a6add385ec85eeaef5', N'image/png', N'truyen-38-chuong-02-tep-1.png', 37531)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (239, 224, 2, N'54bbe5c524375e109364a0f6acd13805', N'image/png', N'truyen-38-chuong-02-tep-2.png', 35746)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (240, 224, 3, N'1a57b0149ed352439f5813e420dc45df', N'image/png', N'truyen-38-chuong-02-tep-3.png', 37110)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (241, 225, 1, N'd34c42da88015a24ab7a8b014315ce52', N'image/png', N'truyen-38-chuong-03-tep-1.png', 37635)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (242, 225, 2, N'0aca4af86bbd50bb88b07a6a3e9aa1f3', N'image/png', N'truyen-38-chuong-03-tep-2.png', 36495)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (243, 225, 3, N'5757273429585535a802624604f21f83', N'image/png', N'truyen-38-chuong-03-tep-3.png', 36713)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (244, 226, 1, N'ca8d976570f256b89f4f1b1b173160ba', N'image/png', N'truyen-38-chuong-04-tep-1.png', 37142)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (245, 226, 2, N'78a5d6c2fe6b53a5aef1c491942e1f9f', N'image/png', N'truyen-38-chuong-04-tep-2.png', 35992)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (246, 226, 3, N'c4f09d815a025dc694e86b40e86e34d2', N'image/png', N'truyen-38-chuong-04-tep-3.png', 36705)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (247, 227, 1, N'aa17fee3850254cb8a641ce03ba3d969', N'image/png', N'truyen-38-chuong-05-tep-1.png', 37138)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (248, 227, 2, N'390dab7e0ea9589ba2e76614c4357a9b', N'image/png', N'truyen-38-chuong-05-tep-2.png', 35992)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (249, 227, 3, N'1f0d3fb208d257b5874844b5f09878a0', N'image/png', N'truyen-38-chuong-05-tep-3.png', 36724)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (250, 228, 1, N'cc2f6031489c5d96abb2bb8b4e37b1a6', N'image/png', N'truyen-38-chuong-06-tep-1.png', 38271)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (251, 228, 2, N'ffc08c79f9c05681b81359f3425b2645', N'image/png', N'truyen-38-chuong-06-tep-2.png', 37114)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (252, 228, 3, N'a0692b45bfda5899b406a8c1ec697d8a', N'image/png', N'truyen-38-chuong-06-tep-3.png', 37867)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (253, 229, 1, N'220e8f68a76a56deb500dd3d5e719dcc', N'image/png', N'truyen-39-chuong-01-tep-1.png', 34977)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (254, 229, 2, N'4c501dcc79af5b0588886d5cec081c04', N'image/png', N'truyen-39-chuong-01-tep-2.png', 34036)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (255, 229, 3, N'6421bc328a0b58918e6a732ce27ff7a4', N'image/png', N'truyen-39-chuong-01-tep-3.png', 34682)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (256, 230, 1, N'fb9c9aeb7b8d57deb737054a955c2aef', N'image/png', N'truyen-39-chuong-02-tep-1.png', 36019)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (257, 230, 2, N'35a8487e40fd581ca4d166adbc16bed1', N'image/png', N'truyen-39-chuong-02-tep-2.png', 34238)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (258, 230, 3, N'3dd88a901f7a5efb9a5a7c9ae2b2dcc7', N'image/png', N'truyen-39-chuong-02-tep-3.png', 35550)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (259, 231, 1, N'462867d72f195a9d90870600bab0dd16', N'image/png', N'truyen-39-chuong-03-tep-1.png', 36124)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (260, 231, 2, N'7e3c433f84a35cf0983b511e75511b27', N'image/png', N'truyen-39-chuong-03-tep-2.png', 34982)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (261, 231, 3, N'9496c3aaf3c6560ea64e69a287dd0848', N'image/png', N'truyen-39-chuong-03-tep-3.png', 35159)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (262, 232, 1, N'04aa1442b70e5e7c84d7704e06e69c1f', N'image/png', N'truyen-39-chuong-04-tep-1.png', 35628)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (263, 232, 2, N'985b7f00092d5126862d4d06e4249421', N'image/png', N'truyen-39-chuong-04-tep-2.png', 34488)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (264, 232, 3, N'9c17300acf0c5c24b11bfb6059d37b37', N'image/png', N'truyen-39-chuong-04-tep-3.png', 35144)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (265, 233, 1, N'eed42ddc06025353b9aaf5fcbc3fdd1f', N'image/png', N'truyen-39-chuong-05-tep-1.png', 35653)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (266, 233, 2, N'd7f720a4b9a05009866c04e10467bf65', N'image/png', N'truyen-39-chuong-05-tep-2.png', 34497)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (267, 233, 3, N'd9e6bf9ea7af54d495471257c16d6dd0', N'image/png', N'truyen-39-chuong-05-tep-3.png', 35179)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (268, 234, 1, N'5c84073e9de955afaf1623a3ea2b58f4', N'image/png', N'truyen-39-chuong-06-tep-1.png', 36780)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (269, 234, 2, N'f25f5799a2f457fc814feddcf90a7e68', N'image/png', N'truyen-39-chuong-06-tep-2.png', 35619)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (270, 234, 3, N'0226306992b756078a21f6b7bf8022d1', N'image/png', N'truyen-39-chuong-06-tep-3.png', 36315)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (271, 235, 1, N'76f48cea59c8518b9b5bbd4d6fc41e54', N'image/png', N'truyen-40-chuong-01-tep-1.png', 35902)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (272, 235, 2, N'a9d43276c7e3509aa761ebfddb62ed3a', N'image/png', N'truyen-40-chuong-01-tep-2.png', 34963)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (273, 235, 3, N'9ef949048d035c05877a6e188ff6866a', N'image/png', N'truyen-40-chuong-01-tep-3.png', 35661)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (274, 236, 1, N'8ec289cf657a555192affaff7c6749ea', N'image/png', N'truyen-40-chuong-02-tep-1.png', 36941)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (275, 236, 2, N'626cf589c2d958e2bf8e33fd847d1ebd', N'image/png', N'truyen-40-chuong-02-tep-2.png', 35161)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (276, 236, 3, N'3241698194cc539d9c20bee9f16314e3', N'image/png', N'truyen-40-chuong-02-tep-3.png', 36522)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (277, 237, 1, N'7949b69f7c28518abee081dc6f127fec', N'image/png', N'truyen-40-chuong-03-tep-1.png', 37047)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (278, 237, 2, N'c73e8f7669e557d48d320fea113d3584', N'image/png', N'truyen-40-chuong-03-tep-2.png', 35904)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (279, 237, 3, N'53df0905252358e58221172c4955c721', N'image/png', N'truyen-40-chuong-03-tep-3.png', 36141)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (280, 238, 1, N'4bc7bed81c4d5dc28282a05117605244', N'image/png', N'truyen-40-chuong-04-tep-1.png', 36555)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (281, 238, 2, N'c27e1971fc40508cb8885383daa9d1a1', N'image/png', N'truyen-40-chuong-04-tep-2.png', 35409)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (282, 238, 3, N'6507359457c453fb814ed2b7bb69c561', N'image/png', N'truyen-40-chuong-04-tep-3.png', 36119)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (283, 239, 1, N'b8eb3738395b57f5a71b3aec92248981', N'image/png', N'truyen-40-chuong-05-tep-1.png', 36577)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (284, 239, 2, N'a91b2251bf465382a891fe7e2ae639c5', N'image/png', N'truyen-40-chuong-05-tep-2.png', 35423)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (285, 239, 3, N'75bbf1144fed5c1e99b30bc5260a9997', N'image/png', N'truyen-40-chuong-05-tep-3.png', 36150)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (286, 240, 1, N'de7bbead8d8a5f50a5d88c2de2db9fd6', N'image/png', N'truyen-40-chuong-06-tep-1.png', 37700)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (287, 240, 2, N'74e06547ae625a4a804cc125d407a9fc', N'image/png', N'truyen-40-chuong-06-tep-2.png', 36540)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (288, 240, 3, N'a8091bea869b5a859de66772c77f2df6', N'image/png', N'truyen-40-chuong-06-tep-3.png', 37280)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (289, 241, 1, N'6c778024ba115ee484194c1135ce0517', N'image/png', N'truyen-41-chuong-01-tep-1.png', 36042)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (290, 241, 2, N'cd59c2112fb95650ba405587e89ebfa4', N'image/png', N'truyen-41-chuong-01-tep-2.png', 35101)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (291, 241, 3, N'b884e59d216e5af1a23b2061de84764f', N'image/png', N'truyen-41-chuong-01-tep-3.png', 35743)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (292, 242, 1, N'153a982f476c526eadd32db6adb54d55', N'image/png', N'truyen-41-chuong-02-tep-1.png', 37077)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (293, 242, 2, N'e4f7c6d4c51e54c0baf81b8c436e3501', N'image/png', N'truyen-41-chuong-02-tep-2.png', 35297)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (294, 242, 3, N'fb35e2ef16e9553392456770b769a3ec', N'image/png', N'truyen-41-chuong-02-tep-3.png', 36605)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (295, 243, 1, N'5b083703a0355cbdbc542d3d03c64913', N'image/png', N'truyen-41-chuong-03-tep-1.png', 37188)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (296, 243, 2, N'423a346fb29956dca18d100f693c6502', N'image/png', N'truyen-41-chuong-03-tep-2.png', 36036)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (297, 243, 3, N'c3cf1c4e8f1155ffa7b3ae3928affe40', N'image/png', N'truyen-41-chuong-03-tep-3.png', 36216)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (298, 244, 1, N'f8a2e57f177b5174a860d913b014d328', N'image/png', N'truyen-41-chuong-04-tep-1.png', 36690)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (299, 244, 2, N'996fe123a9ef5c15a37040478aa1f5f9', N'image/png', N'truyen-41-chuong-04-tep-2.png', 35546)
GO
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (300, 244, 3, N'e8757161f96e547e9ac33299756c586f', N'image/png', N'truyen-41-chuong-04-tep-3.png', 36198)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (301, 245, 1, N'aad376c8f16054e7b80c08631f92cf77', N'image/png', N'truyen-41-chuong-05-tep-1.png', 36708)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (302, 245, 2, N'1d03ca5c274f5db3b9404e7dd3ffa33a', N'image/png', N'truyen-41-chuong-05-tep-2.png', 35560)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (303, 245, 3, N'52c87ebf4b585e8992c6eeed88ef0511', N'image/png', N'truyen-41-chuong-05-tep-3.png', 36233)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (304, 246, 1, N'cc16d858a4ed56e6acc7cb6deb3c814b', N'image/png', N'truyen-41-chuong-06-tep-1.png', 37838)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (305, 246, 2, N'cec6e32e82135592ac4176bd9ee96a84', N'image/png', N'truyen-41-chuong-06-tep-2.png', 36681)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (306, 246, 3, N'33fe494b921b5c9f8ccc31fb5ca63ad5', N'image/png', N'truyen-41-chuong-06-tep-3.png', 37367)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (307, 247, 1, N'4547c965899356c09c9188105115dfac', N'image/png', N'truyen-42-chuong-01-tep-1.png', 36378)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (308, 247, 2, N'0ac8bb77e18d5f25b2842f0dad47ab59', N'image/png', N'truyen-42-chuong-01-tep-2.png', 35444)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (309, 247, 3, N'7678d901750b549284f50a412e282e13', N'image/png', N'truyen-42-chuong-01-tep-3.png', 36133)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (310, 248, 1, N'f4e35479de6855378453406d1a7909bb', N'image/png', N'truyen-42-chuong-02-tep-1.png', 37418)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (311, 248, 2, N'356b4801edc7563ebfde3cc0a180b73e', N'image/png', N'truyen-42-chuong-02-tep-2.png', 35639)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (312, 248, 3, N'037944b2853d580faa4da8d5e83bffb9', N'image/png', N'truyen-42-chuong-02-tep-3.png', 36996)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (313, 249, 1, N'b9529d15c051503d8cd56b3afd501a88', N'image/png', N'truyen-42-chuong-03-tep-1.png', 37525)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (314, 249, 2, N'1d0ca89106e558ccaf6af49a1f2404d7', N'image/png', N'truyen-42-chuong-03-tep-2.png', 36388)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (315, 249, 3, N'0d7914c5afcf5f7786339497669eca07', N'image/png', N'truyen-42-chuong-03-tep-3.png', 36605)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (316, 250, 1, N'cdf555998cc95554b0f79e08de7b330b', N'image/png', N'truyen-42-chuong-04-tep-1.png', 37029)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (317, 250, 2, N'8ef6515b594551e682ef751a63c39eb0', N'image/png', N'truyen-42-chuong-04-tep-2.png', 35889)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (318, 250, 3, N'24b14bbd2a9c591bbbbecc16995f82ca', N'image/png', N'truyen-42-chuong-04-tep-3.png', 36597)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (319, 251, 1, N'730972f903cb569ba4644d26a3433442', N'image/png', N'truyen-42-chuong-05-tep-1.png', 37022)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (320, 251, 2, N'3cdbd02982b350ab92befa5b4dd64e14', N'image/png', N'truyen-42-chuong-05-tep-2.png', 35885)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (321, 251, 3, N'19c14185bc495c228999615a0f02f99e', N'image/png', N'truyen-42-chuong-05-tep-3.png', 36613)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (322, 252, 1, N'a951d4b26fa254dca6e4ceea434bb5d9', N'image/png', N'truyen-42-chuong-06-tep-1.png', 38157)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (323, 252, 2, N'78f3e1897d7d52ffa227c9d4ad863abf', N'image/png', N'truyen-42-chuong-06-tep-2.png', 37005)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (324, 252, 3, N'dd50beacdc0c53ccba09935c3f6ad80c', N'image/png', N'truyen-42-chuong-06-tep-3.png', 37759)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (325, 253, 1, N'7f32f816475e50098f6419b3c850ad36', N'image/png', N'truyen-43-chuong-01-tep-1.png', 36768)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (326, 253, 2, N'9a04816935ce52b1bbd0585f9508f7b5', N'image/png', N'truyen-43-chuong-01-tep-2.png', 35823)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (327, 253, 3, N'1c99b69412cf53cdad02d96db4e5fd60', N'image/png', N'truyen-43-chuong-01-tep-3.png', 36465)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (328, 254, 1, N'cf20c38c295c53a7842cf619a67e5bc1', N'image/png', N'truyen-43-chuong-02-tep-1.png', 37810)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (329, 254, 2, N'fd30d8db14875903a4fc8578a5890bd1', N'image/png', N'truyen-43-chuong-02-tep-2.png', 36027)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (330, 254, 3, N'940bd84c23615a3f95897897375a1fb9', N'image/png', N'truyen-43-chuong-02-tep-3.png', 37332)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (331, 255, 1, N'187a94635ccb5ce9ac394f988000afe3', N'image/png', N'truyen-43-chuong-03-tep-1.png', 37913)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (332, 255, 2, N'db52c9d2cc1458a5ac4010fb6ecfb427', N'image/png', N'truyen-43-chuong-03-tep-2.png', 36768)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (333, 255, 3, N'f92d34a064515881bca242e5326e637a', N'image/png', N'truyen-43-chuong-03-tep-3.png', 36938)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (334, 256, 1, N'8396e6c512a052a2b08ff6f6ea6c3635', N'image/png', N'truyen-43-chuong-04-tep-1.png', 37423)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (335, 256, 2, N'b6c32283ab4a5b008a8f7c2dccf4703a', N'image/png', N'truyen-43-chuong-04-tep-2.png', 36277)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (336, 256, 3, N'824622b946a85e3e90c60a4f2a09c511', N'image/png', N'truyen-43-chuong-04-tep-3.png', 36931)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (337, 257, 1, N'52fe0746f80d534c88049cb8f0231362', N'image/png', N'truyen-43-chuong-05-tep-1.png', 37445)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (338, 257, 2, N'9901ff106db4587a8da854fd458031ab', N'image/png', N'truyen-43-chuong-05-tep-2.png', 36288)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (339, 257, 3, N'5350590688535568a38daab098580a6d', N'image/png', N'truyen-43-chuong-05-tep-3.png', 36965)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (340, 258, 1, N'2d97a0b576d85640834d00428e203813', N'image/png', N'truyen-43-chuong-06-tep-1.png', 38572)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (341, 258, 2, N'50ab67b269ea5efbb4541b0f65af175a', N'image/png', N'truyen-43-chuong-06-tep-2.png', 37405)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (342, 258, 3, N'ed89f625e6055727ab1b5eed455860e6', N'image/png', N'truyen-43-chuong-06-tep-3.png', 38099)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (343, 259, 1, N'b85a7b1981e6566abc11e5e3190629c5', N'image/png', N'truyen-44-chuong-01-tep-1.png', 35956)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (344, 259, 2, N'2d21f106ecef51e689d494d83c9a3846', N'image/png', N'truyen-44-chuong-01-tep-2.png', 35014)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (345, 259, 3, N'cf82ca98bf8d5c10a8912b156441db37', N'image/png', N'truyen-44-chuong-01-tep-3.png', 35715)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (346, 260, 1, N'4674e94a4d285992adf7274de96edb46', N'image/png', N'truyen-44-chuong-02-tep-1.png', 36994)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (347, 260, 2, N'a0a6bd71ca9c50b197049d978c51ee63', N'image/png', N'truyen-44-chuong-02-tep-2.png', 35212)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (348, 260, 3, N'b5e0b5b36385569fb51229ef1f185f6f', N'image/png', N'truyen-44-chuong-02-tep-3.png', 36576)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (349, 261, 1, N'9ff63a039d8e534bb00c76a02317eb2e', N'image/png', N'truyen-44-chuong-03-tep-1.png', 37101)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (350, 261, 2, N'09db5d91855b54b289a61a2494b77c50', N'image/png', N'truyen-44-chuong-03-tep-2.png', 35954)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (351, 261, 3, N'abc4254148c9537cbf86889c95064b0c', N'image/png', N'truyen-44-chuong-03-tep-3.png', 36188)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (352, 262, 1, N'a20d62cbc5b452f69789181c4ba3ddc3', N'image/png', N'truyen-44-chuong-04-tep-1.png', 36608)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (353, 262, 2, N'4cdf46c0d4bf570ca7b7c461bb2d07fe', N'image/png', N'truyen-44-chuong-04-tep-2.png', 35462)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (354, 262, 3, N'7085a9c67c1a5f3f89c305b7b3600281', N'image/png', N'truyen-44-chuong-04-tep-3.png', 36171)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (355, 263, 1, N'4db7766a74c153729722926cd8d2b093', N'image/png', N'truyen-44-chuong-05-tep-1.png', 36629)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (356, 263, 2, N'09fd80845dac5956ac58d9aaa9a15219', N'image/png', N'truyen-44-chuong-05-tep-2.png', 35473)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (357, 263, 3, N'aa7d9dcf5905525f8eee111bf925606d', N'image/png', N'truyen-44-chuong-05-tep-3.png', 36202)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (358, 264, 1, N'ca5259bbf21a5ae29f1d8c4eb2dcb80f', N'image/png', N'truyen-44-chuong-06-tep-1.png', 37755)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (359, 264, 2, N'4e2ed3fa98285efa9f0a0d4008da766c', N'image/png', N'truyen-44-chuong-06-tep-2.png', 36593)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (360, 264, 3, N'd15f4998ed3555b0b4a612a2b45456db', N'image/png', N'truyen-44-chuong-06-tep-3.png', 37335)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (361, 265, 1, N'e22ceb41752a5285975c30e4993ce777', N'image/png', N'truyen-45-chuong-01-tep-1.png', 35893)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (362, 265, 2, N'7cccc321a8f65196be5c1c2b99fec02d', N'image/png', N'truyen-45-chuong-01-tep-2.png', 34946)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (363, 265, 3, N'ab33a90469fb5e89b49599f9ea3feb92', N'image/png', N'truyen-45-chuong-01-tep-3.png', 35596)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (364, 266, 1, N'dfc6ab0754cb5fa58c72b88669f52f13', N'image/png', N'truyen-45-chuong-02-tep-1.png', 36931)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (365, 266, 2, N'b2ae0c7b4ca15643a0a820859457cc13', N'image/png', N'truyen-45-chuong-02-tep-2.png', 35148)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (366, 266, 3, N'c757298cd4cf5cccaed92e6a034b48c0', N'image/png', N'truyen-45-chuong-02-tep-3.png', 36458)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (367, 267, 1, N'c636da0aa45c5fb1ae0b6fb1f9ba9b1b', N'image/png', N'truyen-45-chuong-03-tep-1.png', 37042)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (368, 267, 2, N'f55079e74b8451669d49c12d65790844', N'image/png', N'truyen-45-chuong-03-tep-2.png', 35888)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (369, 267, 3, N'ed0ee38b1938548b861fbf0d399ada0a', N'image/png', N'truyen-45-chuong-03-tep-3.png', 36070)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (370, 268, 1, N'a37c0b7b8bba50d3b5c919a304b643a2', N'image/png', N'truyen-45-chuong-04-tep-1.png', 36541)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (371, 268, 2, N'0ff0ce090cdb5114919036cd311c5a02', N'image/png', N'truyen-45-chuong-04-tep-2.png', 35394)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (372, 268, 3, N'0967721439f75ee7977c8b333d25d06d', N'image/png', N'truyen-45-chuong-04-tep-3.png', 36053)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (373, 269, 1, N'1f0ea26ac9af50899ee0bd2792324579', N'image/png', N'truyen-45-chuong-05-tep-1.png', 36563)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (374, 269, 2, N'23be80c32fd15753ac3542ff74bb8c3d', N'image/png', N'truyen-45-chuong-05-tep-2.png', 35413)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (375, 269, 3, N'41a74cd26892583c9fcf49f5c44c22b4', N'image/png', N'truyen-45-chuong-05-tep-3.png', 36088)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (376, 270, 1, N'3bd0c9d5d5c35c6caa84806a171d0a5c', N'image/png', N'truyen-45-chuong-06-tep-1.png', 37690)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (377, 270, 2, N'c28d0b12703f52b38b405f71d5ee4ad2', N'image/png', N'truyen-45-chuong-06-tep-2.png', 36527)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (378, 270, 3, N'ad7d61cbb40f59169a25453f117fa335', N'image/png', N'truyen-45-chuong-06-tep-3.png', 37216)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (379, 271, 1, N'66a0291b76a45c31878d98388c748335', N'image/png', N'truyen-46-chuong-01-tep-1.png', 36035)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (380, 271, 2, N'ed2c0ce8a75c5914ae7d38c49886282d', N'image/png', N'truyen-46-chuong-01-tep-2.png', 35100)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (381, 271, 3, N'7a8e3d9a2bc65ba8b3f649a0d5a35d8b', N'image/png', N'truyen-46-chuong-01-tep-3.png', 35786)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (382, 272, 1, N'557b72764ab555769070749728c55f0d', N'image/png', N'truyen-46-chuong-02-tep-1.png', 37073)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (383, 272, 2, N'01e7a368458952b690627eecbd805308', N'image/png', N'truyen-46-chuong-02-tep-2.png', 35294)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (384, 272, 3, N'dbaf275c8c855ffc8e393c7dacecff9c', N'image/png', N'truyen-46-chuong-02-tep-3.png', 36652)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (385, 273, 1, N'e98fc93516a15bcdb01843c384d9634a', N'image/png', N'truyen-46-chuong-03-tep-1.png', 37180)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (386, 273, 2, N'76e7f1e9daf757ebb80327e28ffb3401', N'image/png', N'truyen-46-chuong-03-tep-2.png', 36042)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (387, 273, 3, N'5754bcc06262576aabddfb67f1a2c04e', N'image/png', N'truyen-46-chuong-03-tep-3.png', 36259)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (388, 274, 1, N'afa75581140054b7bb81e52d14c61840', N'image/png', N'truyen-46-chuong-04-tep-1.png', 36686)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (389, 274, 2, N'ecf76b9163ec5f2eba6f1c95e36d0a5c', N'image/png', N'truyen-46-chuong-04-tep-2.png', 35544)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (390, 274, 3, N'3a853fb0f6c359ca9ae163bbc6c2231f', N'image/png', N'truyen-46-chuong-04-tep-3.png', 36250)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (391, 275, 1, N'fc5546da1e3150e88c96e4c182759a32', N'image/png', N'truyen-46-chuong-05-tep-1.png', 36682)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (392, 275, 2, N'a9cac1f0f1175d0c98d062b58cf6da34', N'image/png', N'truyen-46-chuong-05-tep-2.png', 35539)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (393, 275, 3, N'708f01b43f8856f9821a393fbe10a887', N'image/png', N'truyen-46-chuong-05-tep-3.png', 36268)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (394, 276, 1, N'8fad04a37098563a955d85ebe5bfe099', N'image/png', N'truyen-46-chuong-06-tep-1.png', 37813)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (395, 276, 2, N'37af0e79bf5352449876509ef48ec995', N'image/png', N'truyen-46-chuong-06-tep-2.png', 36661)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (396, 276, 3, N'4fca53bc10135dfe94f4bf9a4f233b35', N'image/png', N'truyen-46-chuong-06-tep-3.png', 37412)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (397, 277, 1, N'ffcbad13af9e560b80f8f167987e1857', N'image/png', N'truyen-47-chuong-01-tep-1.png', 35390)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (398, 277, 2, N'13ad87404f9a531680000ad437a70022', N'image/png', N'truyen-47-chuong-01-tep-2.png', 34448)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (399, 277, 3, N'd13d7b7fcf4c5fcfa43c9a186e723d1d', N'image/png', N'truyen-47-chuong-01-tep-3.png', 35090)
GO
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (400, 278, 1, N'c569315a86895a8d93522a633f032a8a', N'image/png', N'truyen-47-chuong-02-tep-1.png', 36434)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (401, 278, 2, N'60d7a3239183562db3a77e327d61f413', N'image/png', N'truyen-47-chuong-02-tep-2.png', 34654)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (402, 278, 3, N'75877e51b1ff525f910c42ab21b429aa', N'image/png', N'truyen-47-chuong-02-tep-3.png', 35960)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (403, 279, 1, N'ac5ba48fd5aa5e41be51a3ecb1e5f535', N'image/png', N'truyen-47-chuong-03-tep-1.png', 36540)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (404, 279, 2, N'7c6bc6d0413a5131b89c378a95dc9e27', N'image/png', N'truyen-47-chuong-03-tep-2.png', 35397)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (405, 279, 3, N'd9041bcc2be8537c8e4c7b06a31c26c1', N'image/png', N'truyen-47-chuong-03-tep-3.png', 35568)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (406, 280, 1, N'807eaef2289d5f45992e463b4c845e57', N'image/png', N'truyen-47-chuong-04-tep-1.png', 36047)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (407, 280, 2, N'49b929c75cf958ba91f6b020eab42d13', N'image/png', N'truyen-47-chuong-04-tep-2.png', 34901)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (408, 280, 3, N'c0867943bad65df38e0fd060ebb4eb80', N'image/png', N'truyen-47-chuong-04-tep-3.png', 35558)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (409, 281, 1, N'acf3a8ceb54750aca07ae26840eeaf26', N'image/png', N'truyen-47-chuong-05-tep-1.png', 36070)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (410, 281, 2, N'eb0f0792d0475b1aae52e448b48b03de', N'image/png', N'truyen-47-chuong-05-tep-2.png', 34910)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (411, 281, 3, N'e3103cc029ca5fda805fc500c775cdce', N'image/png', N'truyen-47-chuong-05-tep-3.png', 35590)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (412, 282, 1, N'aee21a1c1d595e938280516490e87c7c', N'image/png', N'truyen-47-chuong-06-tep-1.png', 37193)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (413, 282, 2, N'9c7b7f003ab957c697d739849f860fec', N'image/png', N'truyen-47-chuong-06-tep-2.png', 36032)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (414, 282, 3, N'cd5c6bc360435aa9ad0baa1433dcfc12', N'image/png', N'truyen-47-chuong-06-tep-3.png', 36725)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (415, 283, 1, N'5a4ae21a231d591fabc3897b0a16dafc', N'image/png', N'truyen-48-chuong-01-tep-1.png', 35940)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (416, 283, 2, N'4997cae7b2cd530fbb95aa9fb412c283', N'image/png', N'truyen-48-chuong-01-tep-2.png', 34997)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (417, 283, 3, N'2f125e7046d05be5a1fd585854f4aaf1', N'image/png', N'truyen-48-chuong-01-tep-3.png', 35700)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (418, 284, 1, N'9def4c5570855b7084d238381cbf8d3c', N'image/png', N'truyen-48-chuong-02-tep-1.png', 36980)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (419, 284, 2, N'3bf07811bfa6535ead6063b09cf54a76', N'image/png', N'truyen-48-chuong-02-tep-2.png', 35194)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (420, 284, 3, N'1e96fbb20faf5d838b9fbba58af0b26e', N'image/png', N'truyen-48-chuong-02-tep-3.png', 36560)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (421, 285, 1, N'8904645a94875f8e86fe54a6ca036ce7', N'image/png', N'truyen-48-chuong-03-tep-1.png', 37087)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (422, 285, 2, N'904069ba3569587e971e8daac689ae43', N'image/png', N'truyen-48-chuong-03-tep-2.png', 35939)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (423, 285, 3, N'3cce28f5cbc05b76a2c186d41a83a818', N'image/png', N'truyen-48-chuong-03-tep-3.png', 36175)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (424, 286, 1, N'13e5992859ff53eea70728be9bb6a5a1', N'image/png', N'truyen-48-chuong-04-tep-1.png', 36594)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (425, 286, 2, N'e8a99ad1666254258d8978d22733d7d2', N'image/png', N'truyen-48-chuong-04-tep-2.png', 35450)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (426, 286, 3, N'e951ef3479eb574c972d4e50e9e41def', N'image/png', N'truyen-48-chuong-04-tep-3.png', 36158)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (427, 287, 1, N'19eb7fe872ca56e99ea94a6c94ab0805', N'image/png', N'truyen-48-chuong-05-tep-1.png', 36613)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (428, 287, 2, N'249222231bc553dc91773ccd28e97cc3', N'image/png', N'truyen-48-chuong-05-tep-2.png', 35458)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (429, 287, 3, N'bc8f96f096205607b9d559491ef247df', N'image/png', N'truyen-48-chuong-05-tep-3.png', 36189)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (430, 288, 1, N'a2e3a1a951f554149fb87c39919bfca9', N'image/png', N'truyen-48-chuong-06-tep-1.png', 37738)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (431, 288, 2, N'3c8c377bfc0b524f8578095933b8ba53', N'image/png', N'truyen-48-chuong-06-tep-2.png', 36577)
INSERT [dbo].[NoiDungChuong] ([MaNoiDung], [MaChuong], [ThuTu], [DuongDanTep], [KieuTep], [TenTepGoc], [DungLuong]) VALUES (432, 288, 3, N'52be991ae0bc58068181f3c35d551423', N'image/png', N'truyen-48-chuong-06-tep-3.png', 37318)
SET IDENTITY_INSERT [dbo].[NoiDungChuong] OFF
GO
SET IDENTITY_INSERT [dbo].[Sach] ON 

INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (1, N'Ngọn đèn bên bến sương', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại bến sông, một lá thư mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 14, CAST(N'2026-08-12T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T14:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (2, N'Cánh cửa dưới gốc đa', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại khu phố cũ, một cuốn sổ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 28, CAST(N'2026-08-11T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T13:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (3, N'Bản đồ của người giữ gió', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thung lũng, một chiếc la bàn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 42, CAST(N'2026-08-10T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T12:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (4, N'Những lá thư từ đảo xa', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại nhà ga, một hộp gỗ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 14, CAST(N'2026-08-09T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T11:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (5, N'Nhà ga vào mùa mưa', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại hòn đảo, một tấm bưu thiếp mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 28, CAST(N'2026-08-08T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T10:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (6, N'Hành trình qua thung lũng xanh', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại xưởng gỗ, một ngọn đèn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 42, CAST(N'2026-08-07T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T09:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (7, N'Tiệm sách mở lúc bình minh', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thư viện, một chiếc chìa khóa mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 14, CAST(N'2026-08-06T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T08:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (8, N'Người trồng sao trên mái nhà', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại khu vườn, một tấm bản đồ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 28, CAST(N'2026-08-05T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T07:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (9, N'Dấu chân trong thư viện', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại bến sông, một lá thư mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 42, CAST(N'2026-08-04T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T06:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (10, N'Chiếc đồng hồ không có kim', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại khu phố cũ, một cuốn sổ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 1, 0, 0, CAST(N'2026-08-03T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T05:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (11, N'Mùa hè ở xóm ven sông', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thung lũng, một chiếc la bàn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 1, 0, 0, CAST(N'2026-08-02T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T04:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (12, N'Khu vườn sau bức tường', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại nhà ga, một hộp gỗ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 1, 0, CAST(N'2026-08-01T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T03:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (13, N'Bí mật của phố đèn lồng', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại hòn đảo, một tấm bưu thiếp mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 14, CAST(N'2026-07-31T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T02:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (14, N'Chuyến tàu đi về phía biển', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại xưởng gỗ, một ngọn đèn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 28, CAST(N'2026-07-30T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T01:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (15, N'Âm thanh trong hộp gỗ', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thư viện, một chiếc chìa khóa mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 42, CAST(N'2026-07-29T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-11T00:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (16, N'Nhật ký người gác rừng', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại khu vườn, một tấm bản đồ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 14, CAST(N'2026-07-28T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T23:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (17, N'Một ngày chậm giữa thành phố', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại bến sông, một lá thư mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 28, CAST(N'2026-07-27T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T22:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (18, N'Cô bé và chiếc la bàn', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại khu phố cũ, một cuốn sổ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 42, CAST(N'2026-07-26T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T21:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (19, N'Sổ tay của người sửa máy', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thung lũng, một chiếc la bàn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 14, CAST(N'2026-07-25T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T20:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (20, N'Những người bạn ở trạm mây', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại nhà ga, một hộp gỗ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 28, CAST(N'2026-07-24T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T19:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (21, N'Lời hẹn bên cầu đá', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại hòn đảo, một tấm bưu thiếp mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 42, CAST(N'2026-07-23T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T18:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (22, N'Dòng sông nhớ những cái tên', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại xưởng gỗ, một ngọn đèn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 1, 0, 0, CAST(N'2026-07-22T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T17:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (23, N'Bức tranh chưa khô màu', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thư viện, một chiếc chìa khóa mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 1, 0, 0, CAST(N'2026-07-21T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T16:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (24, N'Chuyện nhỏ trong căn bếp', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại khu vườn, một tấm bản đồ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 1, 0, CAST(N'2026-07-20T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T15:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (25, N'Thí nghiệm ở sân sau', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại bến sông, một lá thư mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 14, CAST(N'2026-07-19T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T14:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (26, N'Mật mã trên tấm bưu thiếp', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại khu phố cũ, một cuốn sổ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 28, CAST(N'2026-07-18T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T13:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (27, N'Con đường qua miền cát', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thung lũng, một chiếc la bàn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 42, CAST(N'2026-07-17T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T12:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (28, N'Ngày trở về làng cũ', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại nhà ga, một hộp gỗ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 14, CAST(N'2026-07-16T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T11:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (29, N'Gió qua cửa sổ tầng ba', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại hòn đảo, một tấm bưu thiếp mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 28, CAST(N'2026-07-15T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T10:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (30, N'Bản nhạc của buổi chiều', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại xưởng gỗ, một ngọn đèn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 42, CAST(N'2026-07-14T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T09:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (31, N'Dưới mái hiên tháng sáu', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thư viện, một chiếc chìa khóa mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 14, CAST(N'2026-07-13T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T08:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (32, N'Người kể chuyện ở quảng trường', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại khu vườn, một tấm bản đồ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 0, 28, CAST(N'2026-07-12T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T07:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (33, N'Xưởng chế tạo những điều vui', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại bến sông, một lá thư mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 0, 0, 42, CAST(N'2026-07-11T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T06:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (34, N'Cách một hạt mầm lớn lên', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại khu phố cũ, một cuốn sổ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 1, 0, 0, CAST(N'2026-07-10T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T05:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (35, N'Lối đi giữa hai ngọn đồi', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thung lũng, một chiếc la bàn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 1, 3, 1, 0, 0, CAST(N'2026-07-09T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T04:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (36, N'Một chiếc ghế dành cho bạn', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại nhà ga, một hộp gỗ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 0, 0, 4, 0, 1, 0, CAST(N'2026-07-08T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T03:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (37, N'Mèo Mây và phố nhỏ', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại hòn đảo, một tấm bưu thiếp mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 1, 3, 0, 0, 14, CAST(N'2026-07-07T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T02:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (38, N'Đội thám hiểm cầu vồng', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại xưởng gỗ, một ngọn đèn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 0, 4, 0, 0, 28, CAST(N'2026-07-06T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T01:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (39, N'Robot Nâu tìm bạn', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thư viện, một chiếc chìa khóa mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 1, 3, 0, 0, 42, CAST(N'2026-07-05T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-10T00:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (40, N'Ba đứa trẻ ở bến xe', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại khu vườn, một tấm bản đồ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 0, 4, 0, 0, 14, CAST(N'2026-07-04T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T23:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (41, N'Cáo Cam giữ khu vườn', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại bến sông, một lá thư mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 1, 3, 0, 0, 28, CAST(N'2026-07-03T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T22:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (42, N'Chuyến giao hàng của Gấu', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại khu phố cũ, một cuốn sổ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 0, 4, 0, 0, 42, CAST(N'2026-07-02T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T21:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (43, N'Vườn sao trong chiếc hộp', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thung lũng, một chiếc la bàn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 1, 3, 0, 0, 14, CAST(N'2026-07-01T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T20:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (44, N'Quán bánh dưới tán cây', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại nhà ga, một hộp gỗ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 0, 4, 0, 0, 28, CAST(N'2026-06-30T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T19:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (45, N'Đảo nổi của những chú chim', N'An Mộc (mẫu)', N'[TRUYỆN MẪU] Tại hòn đảo, một tấm bưu thiếp mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 1, 3, 0, 0, 42, CAST(N'2026-06-29T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T18:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (46, N'Đường đua xe giấy', N'Bình Vũ (mẫu)', N'[TRUYỆN MẪU] Tại xưởng gỗ, một ngọn đèn mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 0, 4, 1, 0, 0, CAST(N'2026-06-28T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T17:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (47, N'Hai chị em và mùa gió', N'Chi Lam (mẫu)', N'[TRUYỆN MẪU] Tại thư viện, một chiếc chìa khóa mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 1, 3, 1, 0, 0, CAST(N'2026-06-27T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T16:08:15.5400000' AS DateTime2), NULL, NULL)
INSERT [dbo].[Sach] ([MaSach], [TenSach], [TacGia], [GioiThieu], [LoaiTruyen], [TrangThaiSangTac], [MaNguoiDang], [ChoDuyet], [BiAn], [LuotDoc], [NgayTao], [NgayCapNhat], [HinhAnhBia], [KieuAnhBia]) VALUES (48, N'Câu lạc bộ sửa đồ cũ', N'Xưởng Mây (mẫu)', N'[TRUYỆN MẪU] Tại khu vườn, một tấm bản đồ mở ra hành trình của An và Bình. Câu chuyện về tình bạn, sự tò mò và cách cùng nhau vượt qua thử thách. Có 6 chương để kiểm tra đọc tiếp, tủ sách, đánh giá và bình luận.', 1, 0, 4, 1, 1, 0, CAST(N'2026-06-26T14:08:15.5400000' AS DateTime2), CAST(N'2026-10-09T15:08:15.5400000' AS DateTime2), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Sach] OFF
GO
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (1, 1, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (1, 4, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (2, 2, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (2, 5, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (3, 3, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (3, 6, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (4, 4, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (4, 7, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (5, 5, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (5, 8, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (6, 6, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (6, 1, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (7, 7, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (7, 2, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (8, 8, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (8, 3, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (9, 1, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (9, 4, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (10, 2, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (10, 5, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (11, 3, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (11, 6, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (12, 4, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (12, 7, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (13, 5, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (13, 8, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (14, 6, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (14, 1, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (15, 7, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (15, 2, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (16, 8, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (16, 3, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (17, 1, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (17, 4, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (18, 2, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (18, 5, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (19, 3, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (19, 6, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (20, 4, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (20, 7, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (21, 5, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (21, 8, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (22, 6, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (22, 1, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (23, 7, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (23, 2, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (24, 8, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (24, 3, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (25, 1, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (25, 4, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (26, 2, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (26, 5, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (27, 3, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (27, 6, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (28, 4, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (28, 7, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (29, 5, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (29, 8, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (30, 6, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (30, 1, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (31, 7, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (31, 2, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (32, 8, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (32, 3, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (33, 1, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (33, 4, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (34, 2, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (34, 5, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (35, 3, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (35, 6, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (36, 4, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (36, 7, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (37, 5, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (37, 8, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (38, 6, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (38, 1, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (39, 7, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (39, 2, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (40, 8, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (40, 3, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (41, 1, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (41, 4, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (42, 2, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (42, 5, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (43, 3, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (43, 6, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (44, 4, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (44, 7, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (45, 5, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (45, 8, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (46, 6, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (46, 1, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (47, 7, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (47, 2, 2)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (48, 8, 1)
INSERT [dbo].[SachTheLoai] ([MaSach], [MaTheLoai], [ThuTu]) VALUES (48, 3, 2)
GO
SET IDENTITY_INSERT [dbo].[Tag] ON 

INSERT [dbo].[Tag] ([MaTag], [TenTag]) VALUES (5, N'doc-sach')
INSERT [dbo].[Tag] ([MaTag], [TenTag]) VALUES (1, N'goi-y')
INSERT [dbo].[Tag] ([MaTag], [TenTag]) VALUES (2, N'ky-ao')
INSERT [dbo].[Tag] ([MaTag], [TenTag]) VALUES (4, N'thao-luan')
INSERT [dbo].[Tag] ([MaTag], [TenTag]) VALUES (3, N'truyen-tranh')
INSERT [dbo].[Tag] ([MaTag], [TenTag]) VALUES (6, N'viet-truyen')
SET IDENTITY_INSERT [dbo].[Tag] OFF
GO
SET IDENTITY_INSERT [dbo].[TaiKhoan] ON 

INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (1, N'Admin mẫu', N'admin@demo.local', N'AQAAAAIAAYagAAAAEN5QQnDGb7148XSSKREwp6VUQ6Uxa28KDT6gvFrjPX043SY8uPNyZK0zPX4Dfztl/Q==', N'Admin', 0, N'4d9bd1ec-0bd7-43ff-a583-17d12a499223', CAST(N'2026-10-11T14:08:15.7070000' AS DateTime2))
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (2, N'Kiểm duyệt mẫu', N'kiemduyet@demo.local', N'AQAAAAIAAYagAAAAEAwDEPc04lJ6nyc1l+4iyMPnJoB2D0ZJ19AhXDiaGcDzAygEHlnJ1p/VOyyoRovKFw==', N'Moderator', 0, N'c8d0ea88-cc1c-4bd4-9fec-8e86c235d72b', CAST(N'2026-10-11T14:08:15.8290000' AS DateTime2))
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (3, N'Người kể chuyện', N'donggop@demo.local', N'AQAAAAIAAYagAAAAEF1UwkyeWOH+/iL5iLjuIBZdStKxTxb4W11LKz3T1+XkVE/VAkDF1yPjyrpKyT80Ig==', N'Contributor', 0, N'7e617001-deea-42b5-b812-28bdac112eb3', CAST(N'2026-10-11T14:08:15.9630000' AS DateTime2))
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (4, N'Xưởng truyện tranh', N'donggop2@demo.local', N'AQAAAAIAAYagAAAAEHkybMQAB9kbvgoafQKr312n/6MKUqxPvRX1WVSjDgv/sAIfVA9I2Csk8fkDAKUtYg==', N'Contributor', 0, N'730e7a53-ef4d-44c9-9d74-5fbbed0254ed', CAST(N'2026-10-11T14:08:16.0910000' AS DateTime2))
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (5, N'Độc giả An', N'thanhvien@demo.local', N'AQAAAAIAAYagAAAAEIImHGpCx+Ijx/ccGupdKlQ1yYW4LWdKkciG3B4cimn7+n2efAyxoLrf4CZxSPEn8Q==', N'Member', 0, N'faa17905-886f-4d2f-b79b-e60f52b84c38', CAST(N'2026-10-11T14:08:16.2260000' AS DateTime2))
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (6, N'Độc giả Bình', N'docgia2@demo.local', N'AQAAAAIAAYagAAAAEJWp8MzFzd7hJihMWmbo5I0r7A8W5KGPDKZHTZyq9dCYmAwbuHOe8mQWhUjf7u1ncw==', N'Member', 0, N'648387d8-f187-4d8f-a46e-cae4672e4068', CAST(N'2026-10-11T14:08:16.3500000' AS DateTime2))
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (7, N'Độc giả Chi', N'docgia3@demo.local', N'AQAAAAIAAYagAAAAEJKmD+G4npYqoX4NoKCx67Xyw+UMIVUlTOCjrJHQET3TgvuMXThPGHQGkFe1alhGRw==', N'Member', 0, N'5148ee31-fd18-4743-a0a5-040e7cb2c163', CAST(N'2026-10-11T14:08:16.4820000' AS DateTime2))
INSERT [dbo].[TaiKhoan] ([MaTaiKhoan], [TenHienThi], [Email], [MatKhauHash], [MaVaiTro], [BiKhoa], [DauBaoMat], [NgayTao]) VALUES (8, N'Tài khoản bị khóa', N'bikhoa@demo.local', N'AQAAAAIAAYagAAAAEKBA91VlPGS69M79vsSfwk//tvXrkDgU69qJCwP3hh8NPTfU2eF70tcvXw0klhsPGg==', N'Member', 1, N'5a75757c-c799-4ad0-a447-2c2f34f992ed', CAST(N'2026-10-11T14:08:16.6020000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[TaiKhoan] OFF
GO
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 1, CAST(N'2026-10-11T14:08:24.8130000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 2, CAST(N'2026-10-11T14:08:24.8670000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 3, CAST(N'2026-10-11T14:08:24.8750000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 4, CAST(N'2026-10-11T14:08:24.8820000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 5, CAST(N'2026-10-11T14:08:24.8830000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 6, CAST(N'2026-10-11T14:08:24.8850000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 7, CAST(N'2026-10-11T14:08:24.8850000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (5, 8, CAST(N'2026-10-11T14:08:24.8880000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 9, CAST(N'2026-10-11T14:08:24.8910000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 13, CAST(N'2026-10-11T14:08:24.8930000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 14, CAST(N'2026-10-11T14:08:24.8940000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 15, CAST(N'2026-10-11T14:08:24.8950000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 16, CAST(N'2026-10-11T14:08:24.8970000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 17, CAST(N'2026-10-11T14:08:24.8980000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 18, CAST(N'2026-10-11T14:08:24.8990000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (6, 19, CAST(N'2026-10-11T14:08:24.8990000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 20, CAST(N'2026-10-11T14:08:24.9010000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 21, CAST(N'2026-10-11T14:08:24.9020000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 25, CAST(N'2026-10-11T14:08:24.9040000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 26, CAST(N'2026-10-11T14:08:24.9050000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 27, CAST(N'2026-10-11T14:08:24.9050000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 28, CAST(N'2026-10-11T14:08:24.9100000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 29, CAST(N'2026-10-11T14:08:24.9120000' AS DateTime2))
INSERT [dbo].[TuSach] ([MaTaiKhoan], [MaSach], [NgayLuu]) VALUES (7, 30, CAST(N'2026-10-11T14:08:24.9130000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[TheLoai] ON 

INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (1, N'Kỳ ảo')
INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (8, N'Kỹ năng sống')
INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (6, N'Khoa học')
INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (7, N'Lịch sử')
INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (2, N'Phiêu lưu')
INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (4, N'Tản văn')
INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (5, N'Trinh thám')
INSERT [dbo].[TheLoai] ([MaTheLoai], [TenTheLoai]) VALUES (3, N'Văn học')
SET IDENTITY_INSERT [dbo].[TheLoai] OFF
GO
INSERT [dbo].[VaiTro] ([MaVaiTro], [TenVaiTro]) VALUES (N'Moderator', N'Kiểm duyệt viên')
INSERT [dbo].[VaiTro] ([MaVaiTro], [TenVaiTro]) VALUES (N'Admin', N'Quản trị viên')
INSERT [dbo].[VaiTro] ([MaVaiTro], [TenVaiTro]) VALUES (N'Member', N'Thành viên')
INSERT [dbo].[VaiTro] ([MaVaiTro], [TenVaiTro]) VALUES (N'Contributor', N'Thành viên đóng góp')
GO
/****** Object:  Index [IX_BaiThaoLuan_DienDan]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_BaiThaoLuan_DienDan] ON [dbo].[BaiThaoLuan]
(
	[BiAn] ASC,
	[NgayTao] DESC,
	[MaBaiThaoLuan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ_BaiThaoLuanTag_ThuTu]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[BaiThaoLuanTag] ADD  CONSTRAINT [UQ_BaiThaoLuanTag_ThuTu] UNIQUE NONCLUSTERED 
(
	[MaBaiThaoLuan] ASC,
	[ThuTu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BaiThaoLuanTag_Tag]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_BaiThaoLuanTag_Tag] ON [dbo].[BaiThaoLuanTag]
(
	[MaTag] ASC,
	[MaBaiThaoLuan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BaoCao_HangDoi]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_BaoCao_HangDoi] ON [dbo].[BaoCao]
(
	[DaXuLy] ASC,
	[MaBaoCao] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BinhLuan_Bai]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_BinhLuan_Bai] ON [dbo].[BinhLuan]
(
	[MaBaiThaoLuan] ASC,
	[BiAn] ASC,
	[NgayTao] ASC,
	[MaBinhLuan] ASC
)
WHERE ([MaBaiThaoLuan] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BinhLuan_Cha]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_BinhLuan_Cha] ON [dbo].[BinhLuan]
(
	[MaBinhLuanCha] ASC,
	[BiAn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BinhLuan_Chuong]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_BinhLuan_Chuong] ON [dbo].[BinhLuan]
(
	[MaChuong] ASC,
	[BiAn] ASC,
	[NgayTao] ASC,
	[MaBinhLuan] ASC
)
WHERE ([MaChuong] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BinhLuan_Sach]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_BinhLuan_Sach] ON [dbo].[BinhLuan]
(
	[MaSach] ASC,
	[BiAn] ASC,
	[NgayTao] ASC,
	[MaBinhLuan] ASC
)
WHERE ([MaSach] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ_Chuong_Sach]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[Chuong] ADD  CONSTRAINT [UQ_Chuong_Sach] UNIQUE NONCLUSTERED 
(
	[MaChuong] ASC,
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ_Chuong_So]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[Chuong] ADD  CONSTRAINT [UQ_Chuong_So] UNIQUE NONCLUSTERED 
(
	[MaSach] ASC,
	[SoChuong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DanhGia_Sach]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_DanhGia_Sach] ON [dbo].[DanhGia]
(
	[MaSach] ASC
)
INCLUDE([SoSao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LuotDocSach_Ky]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_LuotDocSach_Ky] ON [dbo].[LuotDocSach]
(
	[ThoiDiem] ASC,
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LuotDocSach_Khach]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_LuotDocSach_Khach] ON [dbo].[LuotDocSach]
(
	[MaSach] ASC,
	[MaKhach] ASC,
	[ThoiDiem] DESC
)
WHERE ([MaKhach] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LuotDocSach_TaiKhoan]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_LuotDocSach_TaiKhoan] ON [dbo].[LuotDocSach]
(
	[MaSach] ASC,
	[MaTaiKhoan] ASC,
	[ThoiDiem] DESC
)
WHERE ([MaTaiKhoan] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_NoiDungChuong_DuongDan]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[NoiDungChuong] ADD  CONSTRAINT [UQ_NoiDungChuong_DuongDan] UNIQUE NONCLUSTERED 
(
	[DuongDanTep] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ_NoiDungChuong_ThuTu]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[NoiDungChuong] ADD  CONSTRAINT [UQ_NoiDungChuong_ThuTu] UNIQUE NONCLUSTERED 
(
	[MaChuong] ASC,
	[ThuTu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Sach_CongKhai_DocNhieu]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_Sach_CongKhai_DocNhieu] ON [dbo].[Sach]
(
	[LuotDoc] DESC,
	[MaSach] DESC
)
WHERE ([ChoDuyet]=(0) AND [BiAn]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Sach_CongKhai_Moi]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_Sach_CongKhai_Moi] ON [dbo].[Sach]
(
	[NgayTao] DESC,
	[MaSach] DESC
)
WHERE ([ChoDuyet]=(0) AND [BiAn]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Sach_NguoiDang]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_Sach_NguoiDang] ON [dbo].[Sach]
(
	[MaNguoiDang] ASC,
	[NgayTao] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ_SachTheLoai_ThuTu]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[SachTheLoai] ADD  CONSTRAINT [UQ_SachTheLoai_ThuTu] UNIQUE NONCLUSTERED 
(
	[MaSach] ASC,
	[ThuTu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SachTheLoai_TheLoai]    Script Date: 14/10/2026 1:56:36 CH ******/
CREATE NONCLUSTERED INDEX [IX_SachTheLoai_TheLoai] ON [dbo].[SachTheLoai]
(
	[MaTheLoai] ASC,
	[MaSach] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_Tag_Ten]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[Tag] ADD  CONSTRAINT [UQ_Tag_Ten] UNIQUE NONCLUSTERED 
(
	[TenTag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_TaiKhoan_Email]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[TaiKhoan] ADD  CONSTRAINT [UQ_TaiKhoan_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_TheLoai_Ten]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[TheLoai] ADD  CONSTRAINT [UQ_TheLoai_Ten] UNIQUE NONCLUSTERED 
(
	[TenTheLoai] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_VaiTro_Ten]    Script Date: 14/10/2026 1:56:36 CH ******/
ALTER TABLE [dbo].[VaiTro] ADD  CONSTRAINT [UQ_VaiTro_Ten] UNIQUE NONCLUSTERED 
(
	[TenVaiTro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BaiThaoLuan] ADD  CONSTRAINT [DF_BaiThaoLuan_BiAn]  DEFAULT ((0)) FOR [BiAn]
GO
ALTER TABLE [dbo].[BaiThaoLuan] ADD  CONSTRAINT [DF_BaiThaoLuan_NgayTao]  DEFAULT (sysutcdatetime()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[BaoCao] ADD  CONSTRAINT [DF_BaoCao_Ngay]  DEFAULT (sysutcdatetime()) FOR [NgayBaoCao]
GO
ALTER TABLE [dbo].[BaoCao] ADD  CONSTRAINT [DF_BaoCao_DaXuLy]  DEFAULT ((0)) FOR [DaXuLy]
GO
ALTER TABLE [dbo].[BinhLuan] ADD  CONSTRAINT [DF_BinhLuan_BiAn]  DEFAULT ((0)) FOR [BiAn]
GO
ALTER TABLE [dbo].[BinhLuan] ADD  CONSTRAINT [DF_BinhLuan_NgayTao]  DEFAULT (sysutcdatetime()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[Chuong] ADD  CONSTRAINT [DF_Chuong_NgayTao]  DEFAULT (sysutcdatetime()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[DanhGia] ADD  CONSTRAINT [DF_DanhGia_Ngay]  DEFAULT (sysutcdatetime()) FOR [NgayDanhGia]
GO
ALTER TABLE [dbo].[LichSuDoc] ADD  CONSTRAINT [DF_LichSuDoc_ThoiGian]  DEFAULT (sysutcdatetime()) FOR [LanDocCuoi]
GO
ALTER TABLE [dbo].[LuotDocSach] ADD  CONSTRAINT [DF_LuotDocSach_ThoiDiem]  DEFAULT (sysutcdatetime()) FOR [ThoiDiem]
GO
ALTER TABLE [dbo].[Sach] ADD  CONSTRAINT [DF_Sach_Loai]  DEFAULT ((0)) FOR [LoaiTruyen]
GO
ALTER TABLE [dbo].[Sach] ADD  CONSTRAINT [DF_Sach_SangTac]  DEFAULT ((0)) FOR [TrangThaiSangTac]
GO
ALTER TABLE [dbo].[Sach] ADD  CONSTRAINT [DF_Sach_ChoDuyet]  DEFAULT ((1)) FOR [ChoDuyet]
GO
ALTER TABLE [dbo].[Sach] ADD  CONSTRAINT [DF_Sach_BiAn]  DEFAULT ((0)) FOR [BiAn]
GO
ALTER TABLE [dbo].[Sach] ADD  CONSTRAINT [DF_Sach_LuotDoc]  DEFAULT ((0)) FOR [LuotDoc]
GO
ALTER TABLE [dbo].[Sach] ADD  CONSTRAINT [DF_Sach_NgayTao]  DEFAULT (sysutcdatetime()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[Sach] ADD  CONSTRAINT [DF_Sach_CapNhat]  DEFAULT (sysutcdatetime()) FOR [NgayCapNhat]
GO
ALTER TABLE [dbo].[TaiKhoan] ADD  CONSTRAINT [DF_TaiKhoan_VaiTro]  DEFAULT ('Member') FOR [MaVaiTro]
GO
ALTER TABLE [dbo].[TaiKhoan] ADD  CONSTRAINT [DF_TaiKhoan_BiKhoa]  DEFAULT ((0)) FOR [BiKhoa]
GO
ALTER TABLE [dbo].[TaiKhoan] ADD  CONSTRAINT [DF_TaiKhoan_DauBaoMat]  DEFAULT (newid()) FOR [DauBaoMat]
GO
ALTER TABLE [dbo].[TaiKhoan] ADD  CONSTRAINT [DF_TaiKhoan_NgayTao]  DEFAULT (sysutcdatetime()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[TuSach] ADD  CONSTRAINT [DF_TuSach_NgayLuu]  DEFAULT (sysutcdatetime()) FOR [NgayLuu]
GO
ALTER TABLE [dbo].[BaiThaoLuan]  WITH CHECK ADD  CONSTRAINT [FK_BaiThaoLuan_TaiKhoan] FOREIGN KEY([MaTaiKhoan])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[BaiThaoLuan] CHECK CONSTRAINT [FK_BaiThaoLuan_TaiKhoan]
GO
ALTER TABLE [dbo].[BaiThaoLuanTag]  WITH CHECK ADD  CONSTRAINT [FK_BaiThaoLuanTag_Bai] FOREIGN KEY([MaBaiThaoLuan])
REFERENCES [dbo].[BaiThaoLuan] ([MaBaiThaoLuan])
GO
ALTER TABLE [dbo].[BaiThaoLuanTag] CHECK CONSTRAINT [FK_BaiThaoLuanTag_Bai]
GO
ALTER TABLE [dbo].[BaiThaoLuanTag]  WITH CHECK ADD  CONSTRAINT [FK_BaiThaoLuanTag_Tag] FOREIGN KEY([MaTag])
REFERENCES [dbo].[Tag] ([MaTag])
GO
ALTER TABLE [dbo].[BaiThaoLuanTag] CHECK CONSTRAINT [FK_BaiThaoLuanTag_Tag]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [FK_BaoCao_Bai] FOREIGN KEY([MaBaiThaoLuan])
REFERENCES [dbo].[BaiThaoLuan] ([MaBaiThaoLuan])
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [FK_BaoCao_Bai]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [FK_BaoCao_BinhLuan] FOREIGN KEY([MaBinhLuan])
REFERENCES [dbo].[BinhLuan] ([MaBinhLuan])
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [FK_BaoCao_BinhLuan]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [FK_BaoCao_NguoiGui] FOREIGN KEY([MaNguoiBaoCao])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [FK_BaoCao_NguoiGui]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [FK_BaoCao_NguoiXuLy] FOREIGN KEY([MaNguoiXuLy])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [FK_BaoCao_NguoiXuLy]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [FK_BaoCao_Sach] FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [FK_BaoCao_Sach]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [FK_BinhLuan_Bai] FOREIGN KEY([MaBaiThaoLuan])
REFERENCES [dbo].[BaiThaoLuan] ([MaBaiThaoLuan])
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [FK_BinhLuan_Bai]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [FK_BinhLuan_Cha] FOREIGN KEY([MaBinhLuanCha])
REFERENCES [dbo].[BinhLuan] ([MaBinhLuan])
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [FK_BinhLuan_Cha]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [FK_BinhLuan_Chuong] FOREIGN KEY([MaChuong])
REFERENCES [dbo].[Chuong] ([MaChuong])
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [FK_BinhLuan_Chuong]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [FK_BinhLuan_Sach] FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [FK_BinhLuan_Sach]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [FK_BinhLuan_TaiKhoan] FOREIGN KEY([MaTaiKhoan])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [FK_BinhLuan_TaiKhoan]
GO
ALTER TABLE [dbo].[Chuong]  WITH CHECK ADD  CONSTRAINT [FK_Chuong_Sach] FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[Chuong] CHECK CONSTRAINT [FK_Chuong_Sach]
GO
ALTER TABLE [dbo].[DanhGia]  WITH CHECK ADD  CONSTRAINT [FK_DanhGia_Sach] FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[DanhGia] CHECK CONSTRAINT [FK_DanhGia_Sach]
GO
ALTER TABLE [dbo].[DanhGia]  WITH CHECK ADD  CONSTRAINT [FK_DanhGia_TaiKhoan] FOREIGN KEY([MaTaiKhoan])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[DanhGia] CHECK CONSTRAINT [FK_DanhGia_TaiKhoan]
GO
ALTER TABLE [dbo].[LichSuDoc]  WITH CHECK ADD  CONSTRAINT [FK_LichSuDoc_Chuong] FOREIGN KEY([MaChuong], [MaSach])
REFERENCES [dbo].[Chuong] ([MaChuong], [MaSach])
GO
ALTER TABLE [dbo].[LichSuDoc] CHECK CONSTRAINT [FK_LichSuDoc_Chuong]
GO
ALTER TABLE [dbo].[LichSuDoc]  WITH CHECK ADD  CONSTRAINT [FK_LichSuDoc_TaiKhoan] FOREIGN KEY([MaTaiKhoan])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[LichSuDoc] CHECK CONSTRAINT [FK_LichSuDoc_TaiKhoan]
GO
ALTER TABLE [dbo].[LuotDocSach]  WITH CHECK ADD  CONSTRAINT [FK_LuotDocSach_Sach] FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[LuotDocSach] CHECK CONSTRAINT [FK_LuotDocSach_Sach]
GO
ALTER TABLE [dbo].[LuotDocSach]  WITH CHECK ADD  CONSTRAINT [FK_LuotDocSach_TaiKhoan] FOREIGN KEY([MaTaiKhoan])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[LuotDocSach] CHECK CONSTRAINT [FK_LuotDocSach_TaiKhoan]
GO
ALTER TABLE [dbo].[NoiDungChuong]  WITH CHECK ADD  CONSTRAINT [FK_NoiDungChuong_Chuong] FOREIGN KEY([MaChuong])
REFERENCES [dbo].[Chuong] ([MaChuong])
GO
ALTER TABLE [dbo].[NoiDungChuong] CHECK CONSTRAINT [FK_NoiDungChuong_Chuong]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [FK_Sach_NguoiDang] FOREIGN KEY([MaNguoiDang])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [FK_Sach_NguoiDang]
GO
ALTER TABLE [dbo].[SachTheLoai]  WITH CHECK ADD  CONSTRAINT [FK_SachTheLoai_Sach] FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[SachTheLoai] CHECK CONSTRAINT [FK_SachTheLoai_Sach]
GO
ALTER TABLE [dbo].[SachTheLoai]  WITH CHECK ADD  CONSTRAINT [FK_SachTheLoai_TheLoai] FOREIGN KEY([MaTheLoai])
REFERENCES [dbo].[TheLoai] ([MaTheLoai])
GO
ALTER TABLE [dbo].[SachTheLoai] CHECK CONSTRAINT [FK_SachTheLoai_TheLoai]
GO
ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [FK_TaiKhoan_VaiTro] FOREIGN KEY([MaVaiTro])
REFERENCES [dbo].[VaiTro] ([MaVaiTro])
GO
ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [FK_TaiKhoan_VaiTro]
GO
ALTER TABLE [dbo].[TuSach]  WITH CHECK ADD  CONSTRAINT [FK_TuSach_Sach] FOREIGN KEY([MaSach])
REFERENCES [dbo].[Sach] ([MaSach])
GO
ALTER TABLE [dbo].[TuSach] CHECK CONSTRAINT [FK_TuSach_Sach]
GO
ALTER TABLE [dbo].[TuSach]  WITH CHECK ADD  CONSTRAINT [FK_TuSach_TaiKhoan] FOREIGN KEY([MaTaiKhoan])
REFERENCES [dbo].[TaiKhoan] ([MaTaiKhoan])
GO
ALTER TABLE [dbo].[TuSach] CHECK CONSTRAINT [FK_TuSach_TaiKhoan]
GO
ALTER TABLE [dbo].[BaiThaoLuan]  WITH CHECK ADD  CONSTRAINT [CK_BaiThaoLuan_NoiDung] CHECK  ((len(ltrim(rtrim([NoiDung])))>(0) AND datalength([NoiDung])<=(10000)))
GO
ALTER TABLE [dbo].[BaiThaoLuan] CHECK CONSTRAINT [CK_BaiThaoLuan_NoiDung]
GO
ALTER TABLE [dbo].[BaiThaoLuan]  WITH CHECK ADD  CONSTRAINT [CK_BaiThaoLuan_TieuDe] CHECK  ((len(ltrim(rtrim([TieuDe])))>(0)))
GO
ALTER TABLE [dbo].[BaiThaoLuan] CHECK CONSTRAINT [CK_BaiThaoLuan_TieuDe]
GO
ALTER TABLE [dbo].[BaiThaoLuanTag]  WITH CHECK ADD  CONSTRAINT [CK_BaiThaoLuanTag_ThuTu] CHECK  (([ThuTu]>=(1) AND [ThuTu]<=(5)))
GO
ALTER TABLE [dbo].[BaiThaoLuanTag] CHECK CONSTRAINT [CK_BaiThaoLuanTag_ThuTu]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [CK_BaoCao_DoiTuong] CHECK  ((((case when [MaSach] IS NOT NULL then (1) else (0) end+case when [MaBaiThaoLuan] IS NOT NULL then (1) else (0) end)+case when [MaBinhLuan] IS NOT NULL then (1) else (0) end)=(1)))
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [CK_BaoCao_DoiTuong]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [CK_BaoCao_LyDo] CHECK  ((len(ltrim(rtrim([LyDo])))>(0)))
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [CK_BaoCao_LyDo]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [CK_BaoCao_Snapshot] CHECK  ((len(ltrim(rtrim([NoiDungBiBaoCao])))>(0)))
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [CK_BaoCao_Snapshot]
GO
ALTER TABLE [dbo].[BaoCao]  WITH CHECK ADD  CONSTRAINT [CK_BaoCao_XuLy] CHECK  (([DaXuLy]=(0) AND [MaNguoiXuLy] IS NULL AND [KetQuaXuLy] IS NULL AND [NgayXuLy] IS NULL OR [DaXuLy]=(1) AND [MaNguoiXuLy] IS NOT NULL AND [KetQuaXuLy] IS NOT NULL AND len(ltrim(rtrim([KetQuaXuLy])))>(0) AND [NgayXuLy] IS NOT NULL AND [NgayXuLy]>=[NgayBaoCao]))
GO
ALTER TABLE [dbo].[BaoCao] CHECK CONSTRAINT [CK_BaoCao_XuLy]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [CK_BinhLuan_Dich] CHECK  ((((case when [MaSach] IS NOT NULL then (1) else (0) end+case when [MaChuong] IS NOT NULL then (1) else (0) end)+case when [MaBaiThaoLuan] IS NOT NULL then (1) else (0) end)=(1)))
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [CK_BinhLuan_Dich]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [CK_BinhLuan_NoiDung] CHECK  ((len(ltrim(rtrim([NoiDung])))>(0)))
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [CK_BinhLuan_NoiDung]
GO
ALTER TABLE [dbo].[BinhLuan]  WITH CHECK ADD  CONSTRAINT [CK_BinhLuan_ThuTuCha] CHECK  (([MaBinhLuanCha] IS NULL OR [MaBinhLuanCha]<[MaBinhLuan]))
GO
ALTER TABLE [dbo].[BinhLuan] CHECK CONSTRAINT [CK_BinhLuan_ThuTuCha]
GO
ALTER TABLE [dbo].[Chuong]  WITH CHECK ADD  CONSTRAINT [CK_Chuong_So] CHECK  (([SoChuong]>(0)))
GO
ALTER TABLE [dbo].[Chuong] CHECK CONSTRAINT [CK_Chuong_So]
GO
ALTER TABLE [dbo].[Chuong]  WITH CHECK ADD  CONSTRAINT [CK_Chuong_TieuDe] CHECK  ((len(ltrim(rtrim([TieuDe])))>(0)))
GO
ALTER TABLE [dbo].[Chuong] CHECK CONSTRAINT [CK_Chuong_TieuDe]
GO
ALTER TABLE [dbo].[DanhGia]  WITH CHECK ADD  CONSTRAINT [CK_DanhGia_Sao] CHECK  (([SoSao]>=(1) AND [SoSao]<=(5)))
GO
ALTER TABLE [dbo].[DanhGia] CHECK CONSTRAINT [CK_DanhGia_Sao]
GO
ALTER TABLE [dbo].[LuotDocSach]  WITH CHECK ADD  CONSTRAINT [CK_LuotDocSach_Nguoi] CHECK  (([MaTaiKhoan] IS NOT NULL AND [MaKhach] IS NULL OR [MaTaiKhoan] IS NULL AND [MaKhach] IS NOT NULL))
GO
ALTER TABLE [dbo].[LuotDocSach] CHECK CONSTRAINT [CK_LuotDocSach_Nguoi]
GO
ALTER TABLE [dbo].[NoiDungChuong]  WITH CHECK ADD  CONSTRAINT [CK_NoiDungChuong_DuongDan] CHECK  ((len([DuongDanTep])>(0) AND NOT [DuongDanTep] like '%[^a-z0-9/._-]%' AND left([DuongDanTep],(1))<>'/' AND right([DuongDanTep],(1))<>'/' AND charindex('..',[DuongDanTep])=(0) AND charindex('//',[DuongDanTep])=(0) AND [DuongDanTep]<>'.' AND left([DuongDanTep],(2))<>'./' AND right([DuongDanTep],(2))<>'/.' AND charindex('/./',[DuongDanTep])=(0)))
GO
ALTER TABLE [dbo].[NoiDungChuong] CHECK CONSTRAINT [CK_NoiDungChuong_DuongDan]
GO
ALTER TABLE [dbo].[NoiDungChuong]  WITH CHECK ADD  CONSTRAINT [CK_NoiDungChuong_Kieu] CHECK  (([KieuTep]='application/pdf' OR [KieuTep]='image/webp' OR [KieuTep]='image/png' OR [KieuTep]='image/jpeg' OR [KieuTep]='text/markdown' OR [KieuTep]='text/plain'))
GO
ALTER TABLE [dbo].[NoiDungChuong] CHECK CONSTRAINT [CK_NoiDungChuong_Kieu]
GO
ALTER TABLE [dbo].[NoiDungChuong]  WITH CHECK ADD  CONSTRAINT [CK_NoiDungChuong_Size] CHECK  (([DungLuong]>(0) AND (NOT ([KieuTep]='image/webp' OR [KieuTep]='image/png' OR [KieuTep]='image/jpeg') OR [DungLuong]<=(5242880))))
GO
ALTER TABLE [dbo].[NoiDungChuong] CHECK CONSTRAINT [CK_NoiDungChuong_Size]
GO
ALTER TABLE [dbo].[NoiDungChuong]  WITH CHECK ADD  CONSTRAINT [CK_NoiDungChuong_Ten] CHECK  ((len(ltrim(rtrim([TenTepGoc])))>(0)))
GO
ALTER TABLE [dbo].[NoiDungChuong] CHECK CONSTRAINT [CK_NoiDungChuong_Ten]
GO
ALTER TABLE [dbo].[NoiDungChuong]  WITH CHECK ADD  CONSTRAINT [CK_NoiDungChuong_ThuTu] CHECK  (([ThuTu]>(0)))
GO
ALTER TABLE [dbo].[NoiDungChuong] CHECK CONSTRAINT [CK_NoiDungChuong_ThuTu]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_AnhBia] CHECK  (([HinhAnhBia] IS NULL AND [KieuAnhBia] IS NULL OR [HinhAnhBia] IS NOT NULL AND [KieuAnhBia] IS NOT NULL AND (datalength([HinhAnhBia])>=(1) AND datalength([HinhAnhBia])<=(5242880)) AND ([KieuAnhBia]='image/webp' OR [KieuAnhBia]='image/png' OR [KieuAnhBia]='image/jpeg')))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_AnhBia]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_GioiThieu] CHECK  ((len(ltrim(rtrim([GioiThieu])))>(0)))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_GioiThieu]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_Loai] CHECK  (([LoaiTruyen]=(1) OR [LoaiTruyen]=(0)))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_Loai]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_LuotDoc] CHECK  (([LuotDoc]>=(0)))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_LuotDoc]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_Ngay] CHECK  (([NgayCapNhat]>=[NgayTao]))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_Ngay]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_SangTac] CHECK  (([TrangThaiSangTac]=(1) OR [TrangThaiSangTac]=(0)))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_SangTac]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_TacGia] CHECK  ((len(ltrim(rtrim([TacGia])))>(0)))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_TacGia]
GO
ALTER TABLE [dbo].[Sach]  WITH CHECK ADD  CONSTRAINT [CK_Sach_Ten] CHECK  ((len(ltrim(rtrim([TenSach])))>(0)))
GO
ALTER TABLE [dbo].[Sach] CHECK CONSTRAINT [CK_Sach_Ten]
GO
ALTER TABLE [dbo].[SachTheLoai]  WITH CHECK ADD  CONSTRAINT [CK_SachTheLoai_ThuTu] CHECK  (([ThuTu]>(0)))
GO
ALTER TABLE [dbo].[SachTheLoai] CHECK CONSTRAINT [CK_SachTheLoai_ThuTu]
GO
ALTER TABLE [dbo].[Tag]  WITH CHECK ADD  CONSTRAINT [CK_Tag_Ten] CHECK  ((len(ltrim(rtrim([TenTag])))>(0) AND charindex(N',',[TenTag])=(0)))
GO
ALTER TABLE [dbo].[Tag] CHECK CONSTRAINT [CK_Tag_Ten]
GO
ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [CK_TaiKhoan_Email] CHECK  ((len([Email])>(3) AND charindex(N'@',[Email])>(1) AND charindex(N' ',[Email])=(0) AND NOT [Email] like (N'%'+nchar((9)))+N'%' AND NOT [Email] like (N'%'+nchar((10)))+N'%' AND NOT [Email] like (N'%'+nchar((13)))+N'%'))
GO
ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [CK_TaiKhoan_Email]
GO
ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [CK_TaiKhoan_Hash] CHECK  ((len(ltrim(rtrim([MatKhauHash])))>(0)))
GO
ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [CK_TaiKhoan_Hash]
GO
ALTER TABLE [dbo].[TaiKhoan]  WITH CHECK ADD  CONSTRAINT [CK_TaiKhoan_Ten] CHECK  ((len(ltrim(rtrim([TenHienThi])))>=(2) AND len(ltrim(rtrim([TenHienThi])))<=(80)))
GO
ALTER TABLE [dbo].[TaiKhoan] CHECK CONSTRAINT [CK_TaiKhoan_Ten]
GO
ALTER TABLE [dbo].[TheLoai]  WITH CHECK ADD  CONSTRAINT [CK_TheLoai_Ten] CHECK  ((len(ltrim(rtrim([TenTheLoai])))>(0)))
GO
ALTER TABLE [dbo].[TheLoai] CHECK CONSTRAINT [CK_TheLoai_Ten]
GO
ALTER TABLE [dbo].[VaiTro]  WITH CHECK ADD  CONSTRAINT [CK_VaiTro_Ma] CHECK  (([MaVaiTro]='Admin' OR [MaVaiTro]='Moderator' OR [MaVaiTro]='Contributor' OR [MaVaiTro]='Member'))
GO
ALTER TABLE [dbo].[VaiTro] CHECK CONSTRAINT [CK_VaiTro_Ma]
GO
/****** Object:  StoredProcedure [dbo].[usp_BangXepHang]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_BangXepHang]
    @Ky varchar(5) -- Day / Week / Month, nhu RankingPeriod cua du an
AS
BEGIN
    SET NOCOUNT ON;
    IF @Ky IS NULL OR @Ky NOT IN('Day','Week','Month') THROW 50016,N'Ky phai la Day, Week hoac Month.',1;
    DECLARE @DenUTC datetime2(3)=SYSUTCDATETIME(),@NgayVN date,@DauVN date,@TuUTC datetime2(3);
    SET @NgayVN=CONVERT(date,DATEADD(hour,7,@DenUTC));
    SET @DauVN=CASE @Ky WHEN 'Day' THEN @NgayVN
        WHEN 'Week' THEN DATEADD(day,-(DATEDIFF(day,CONVERT(date,'19000101',112),@NgayVN)%7),@NgayVN)
        ELSE DATEFROMPARTS(YEAR(@NgayVN),MONTH(@NgayVN),1) END;
    SET @TuUTC=DATEADD(hour,-7,CONVERT(datetime2(3),@DauVN));
    SELECT TOP(10) s.MaSach,s.TenSach,COUNT_BIG(*) AS LuotDocTrongKy
    FROM dbo.LuotDocSach l JOIN dbo.vw_SachCongKhai s ON s.MaSach=l.MaSach
    WHERE l.ThoiDiem>=@TuUTC AND l.ThoiDiem<=@DenUTC
    GROUP BY s.MaSach,s.TenSach
    ORDER BY COUNT_BIG(*) DESC,s.TenSach COLLATE Latin1_General_100_BIN2,s.MaSach;
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_DocChuong]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_DocChuong]
    @MaSach int,@SoChuong int,@MaTaiKhoan int=NULL,@MaKhach uniqueidentifier=NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    IF (@MaTaiKhoan IS NULL AND @MaKhach IS NULL) OR (@MaTaiKhoan IS NOT NULL AND @MaKhach IS NOT NULL)
        THROW 50015,N'Can dung mot dinh danh: tai khoan hoac cookie khach.',1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @MaTaiKhoan IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.TaiKhoan WITH(HOLDLOCK)
            WHERE MaTaiKhoan=@MaTaiKhoan AND BiKhoa=0) THROW 50005,N'Tai khoan khong hop le.',1;
        DECLARE @Sach int,@MaChuong int,@Luc datetime2(3),@LanTruoc datetime2(3),@DaTinh bit=0;
        SELECT @Sach=MaSach FROM dbo.Sach WITH(UPDLOCK,HOLDLOCK) WHERE MaSach=@MaSach AND ChoDuyet=0 AND BiAn=0;
        IF @Sach IS NULL THROW 50006,N'Sach chua cong khai.',1;
        SELECT @MaChuong=MaChuong FROM dbo.Chuong WHERE MaSach=@MaSach AND SoChuong=@SoChuong;
        IF @MaChuong IS NULL THROW 50006,N'Chuong khong ton tai.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.NoiDungChuong WHERE MaChuong=@MaChuong)
            THROW 50017,N'Chuong chua co tep noi dung.',1;
        -- Lay gio SAU khi da lay khoa: request doi khoa khong mang moc gio cu.
        SET @Luc=SYSUTCDATETIME();
        IF @MaTaiKhoan IS NULL
            SELECT @LanTruoc=MAX(ThoiDiem) FROM dbo.LuotDocSach WHERE MaSach=@MaSach AND MaKhach=@MaKhach;
        IF @MaTaiKhoan IS NOT NULL OR @LanTruoc IS NULL OR @LanTruoc<=DATEADD(minute,-30,@Luc)
        BEGIN
            INSERT dbo.LuotDocSach(MaSach,MaTaiKhoan,MaKhach,ThoiDiem) VALUES(@MaSach,@MaTaiKhoan,@MaKhach,@Luc);
            UPDATE dbo.Sach SET LuotDoc=LuotDoc+1 WHERE MaSach=@MaSach;
            SET @DaTinh=1;
        END;
        -- Lich su giu chuong moi nhat; moi lan doc cua tai khoan deu cong luot.
        IF @MaTaiKhoan IS NOT NULL
        BEGIN
            UPDATE dbo.LichSuDoc WITH(UPDLOCK,HOLDLOCK) SET MaChuong=@MaChuong,LanDocCuoi=@Luc
            WHERE MaTaiKhoan=@MaTaiKhoan AND MaSach=@MaSach;
            IF @@ROWCOUNT=0 INSERT dbo.LichSuDoc(MaTaiKhoan,MaSach,MaChuong,LanDocCuoi) VALUES(@MaTaiKhoan,@MaSach,@MaChuong,@Luc);
        END;
        SELECT c.*,s.TenSach,@DaTinh AS DaTinhLuot,
            (SELECT COUNT(*) FROM dbo.Chuong WHERE MaSach=@MaSach) AS TongSoChuong
        FROM dbo.Chuong c JOIN dbo.Sach s ON s.MaSach=c.MaSach WHERE c.MaChuong=@MaChuong;
        SELECT MaNoiDung,ThuTu,DuongDanTep,KieuTep,TenTepGoc,DungLuong FROM dbo.NoiDungChuong WHERE MaChuong=@MaChuong ORDER BY ThuTu;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_LayTepNoiDung]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LayTepNoiDung]
    @MaNoiDung int,@MaTaiKhoan int=NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Dung endpoint nay cho ca anh/PDF/TXT. Khong cong luot doc khi lay tung tep.
    SELECT n.MaNoiDung,n.MaChuong,n.DuongDanTep,n.KieuTep,n.TenTepGoc,n.DungLuong
    FROM dbo.NoiDungChuong n JOIN dbo.Chuong c ON c.MaChuong=n.MaChuong JOIN dbo.Sach s ON s.MaSach=c.MaSach
    WHERE n.MaNoiDung=@MaNoiDung AND (
       (s.ChoDuyet=0 AND s.BiAn=0) OR EXISTS(SELECT 1 FROM dbo.TaiKhoan u
          WHERE u.MaTaiKhoan=@MaTaiKhoan AND u.BiKhoa=0 AND (u.MaVaiTro IN('Admin','Moderator')
            OR (u.MaVaiTro='Contributor' AND s.MaNguoiDang=u.MaTaiKhoan))));
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_LuuDanhGia]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LuuDanhGia]
    @MaTaiKhoan int, @MaSach int, @SoSao int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @SoSao IS NULL OR @SoSao NOT BETWEEN 1 AND 5 THROW 50007,N'So sao phai tu 1 den 5.',1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS(SELECT 1 FROM dbo.TaiKhoan WITH(HOLDLOCK) WHERE MaTaiKhoan=@MaTaiKhoan AND BiKhoa=0)
            THROW 50005,N'Tai khoan khong hop le.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.Sach WITH(HOLDLOCK) WHERE MaSach=@MaSach AND ChoDuyet=0 AND BiAn=0)
            THROW 50008,N'Sach chua cong khai.',1;
        UPDATE dbo.DanhGia WITH(UPDLOCK,HOLDLOCK) SET SoSao=@SoSao,NgayDanhGia=SYSUTCDATETIME()
        WHERE MaTaiKhoan=@MaTaiKhoan AND MaSach=@MaSach;
        IF @@ROWCOUNT=0 INSERT dbo.DanhGia(MaTaiKhoan,MaSach,SoSao) VALUES(@MaTaiKhoan,@MaSach,@SoSao);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH
END;

GO
/****** Object:  StoredProcedure [dbo].[usp_LuuTuSach]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LuuTuSach]
    @MaTaiKhoan int, @MaSach int, @Luu bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Luu IS NULL THROW 50009,N'Phai chi dinh luu hoac bo luu.',1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS(SELECT 1 FROM dbo.TaiKhoan WITH(HOLDLOCK) WHERE MaTaiKhoan=@MaTaiKhoan AND BiKhoa=0)
            THROW 50005,N'Tai khoan khong hop le.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.Sach WITH(HOLDLOCK) WHERE MaSach=@MaSach AND ChoDuyet=0 AND BiAn=0)
            THROW 50008,N'Sach chua cong khai.',1;
        IF @Luu=0 DELETE dbo.TuSach WHERE MaTaiKhoan=@MaTaiKhoan AND MaSach=@MaSach;
        ELSE IF NOT EXISTS(SELECT 1 FROM dbo.TuSach WITH(UPDLOCK,HOLDLOCK)
                           WHERE MaTaiKhoan=@MaTaiKhoan AND MaSach=@MaSach)
            INSERT dbo.TuSach(MaTaiKhoan,MaSach) VALUES(@MaTaiKhoan,@MaSach);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH
END;

GO
/****** Object:  StoredProcedure [dbo].[usp_ThemBinhLuan]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ThemBinhLuan]
    @MaTaiKhoan int,@NoiDung nvarchar(max),@MaSach int=NULL,@MaChuong int=NULL,
    @MaBaiThaoLuan int=NULL,@MaBinhLuanCha int=NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    IF @NoiDung IS NULL OR LEN(LTRIM(RTRIM(@NoiDung)))=0 OR DATALENGTH(@NoiDung)>4000
        THROW 50020,N'Binh luan bat buoc, toi da 2000 ky tu.',1;
    IF (CASE WHEN @MaSach IS NULL THEN 0 ELSE 1 END)+(CASE WHEN @MaChuong IS NULL THEN 0 ELSE 1 END)
       +(CASE WHEN @MaBaiThaoLuan IS NULL THEN 0 ELSE 1 END)<>1 THROW 50021,N'Chi chon mot pham vi binh luan.',1;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS(SELECT 1 FROM dbo.TaiKhoan WITH(HOLDLOCK) WHERE MaTaiKhoan=@MaTaiKhoan AND BiKhoa=0)
            THROW 50005,N'Tai khoan khong hop le.',1;
        IF @MaSach IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Sach WITH(HOLDLOCK) WHERE MaSach=@MaSach AND ChoDuyet=0 AND BiAn=0)
            THROW 50008,N'Sach chua cong khai.',1;
        IF @MaChuong IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Chuong c WITH(HOLDLOCK)
            JOIN dbo.Sach s WITH(HOLDLOCK) ON s.MaSach=c.MaSach WHERE c.MaChuong=@MaChuong AND s.ChoDuyet=0 AND s.BiAn=0)
            THROW 50006,N'Chuong khong ton tai hoac sach chua cong khai.',1;
        IF @MaBaiThaoLuan IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.BaiThaoLuan WITH(HOLDLOCK) WHERE MaBaiThaoLuan=@MaBaiThaoLuan AND BiAn=0)
            THROW 50022,N'Bai thao luan khong cong khai.',1;
        -- Kiem tra TOAN BO to tien va cung pham vi; HOLDLOCK giu trang thai den khi commit.
        DECLARE @Cha int=@MaBinhLuanCha,@Ke int,@SachCha int,@ChuongCha int,@BaiCha int,@An bit;
        WHILE @Cha IS NOT NULL
        BEGIN
            SET @An=NULL; SET @Ke=NULL;
            SELECT @Ke=MaBinhLuanCha,@SachCha=MaSach,@ChuongCha=MaChuong,@BaiCha=MaBaiThaoLuan,@An=BiAn
            FROM dbo.BinhLuan WITH(HOLDLOCK) WHERE MaBinhLuan=@Cha;
            IF @An IS NULL OR @An=1 THROW 50023,N'Binh luan cha/to tien khong hien thi.',1;
            IF EXISTS(SELECT @MaSach,@MaChuong,@MaBaiThaoLuan EXCEPT SELECT @SachCha,@ChuongCha,@BaiCha)
                THROW 50101,N'Khong duoc tra loi cheo pham vi.',1;
            SET @Cha=@Ke;
        END;
        INSERT dbo.BinhLuan(MaSach,MaChuong,MaBaiThaoLuan,MaBinhLuanCha,MaTaiKhoan,NoiDung)
        VALUES(@MaSach,@MaChuong,@MaBaiThaoLuan,@MaBinhLuanCha,@MaTaiKhoan,LTRIM(RTRIM(@NoiDung)));
        DECLARE @MaMoi int=CONVERT(int,SCOPE_IDENTITY());
        COMMIT;
        SELECT @MaMoi AS MaBinhLuan;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_ThemChuong]    Script Date: 14/10/2026 1:56:36 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ThemChuong]
    @MaNguoiThaoTac int,@MaSach int,@TieuDe nvarchar(max),@Tep dbo.DanhSachTepNoiDung READONLY
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @N int=(SELECT COUNT(*) FROM @Tep);
    IF @TieuDe IS NULL OR LEN(LTRIM(RTRIM(@TieuDe)))=0 OR DATALENGTH(@TieuDe)>320
        THROW 50011,N'Tieu de bat buoc, toi da 160 ky tu.',1;
    IF @N=0 OR (SELECT MIN(ThuTu) FROM @Tep)<>1 OR (SELECT MAX(ThuTu) FROM @Tep)<>@N
        THROW 50012,N'Can it nhat mot tep, thu tu lien tuc tu 1.',1;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @VaiTro varchar(20),@Chu int,@So int,@MaChuong int;
        SELECT @VaiTro=MaVaiTro FROM dbo.TaiKhoan WITH(HOLDLOCK) WHERE MaTaiKhoan=@MaNguoiThaoTac AND BiKhoa=0;
        IF @VaiTro IS NULL OR @VaiTro NOT IN('Contributor','Admin') THROW 50002,N'Khong co quyen dang chuong.',1;
        SELECT @Chu=MaNguoiDang FROM dbo.Sach WITH(UPDLOCK,HOLDLOCK) WHERE MaSach=@MaSach;
        IF @Chu IS NULL THROW 50003,N'Sach khong ton tai.',1;
        IF @VaiTro<>'Admin' AND @Chu<>@MaNguoiThaoTac THROW 50004,N'Khong phai sach cua ban.',1;
        SELECT @So=ISNULL(MAX(SoChuong),0)+1 FROM dbo.Chuong WHERE MaSach=@MaSach;
        INSERT dbo.Chuong(MaSach,SoChuong,TieuDe) VALUES(@MaSach,@So,LTRIM(RTRIM(@TieuDe)));
        SET @MaChuong=CONVERT(int,SCOPE_IDENTITY());
        INSERT dbo.NoiDungChuong(MaChuong,ThuTu,DuongDanTep,KieuTep,TenTepGoc,DungLuong)
        SELECT @MaChuong,ThuTu,DuongDanTep,KieuTep,TenTepGoc,DungLuong FROM @Tep;
        UPDATE dbo.Sach SET ChoDuyet=CASE WHEN @VaiTro='Admin' THEN ChoDuyet ELSE 1 END,
            NgayCapNhat=SYSUTCDATETIME() WHERE MaSach=@MaSach;
        COMMIT;
        SELECT @MaChuong AS MaChuong,@So AS SoChuong;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
EXEC [SachMoiDaDen].sys.sp_addextendedproperty @name=N'SachMoiDaDen.Demo.v1', @value=N'48 books / 288 chapters / 8 accounts' 
GO

-- Trigger nghiep vu tu script V3.
CREATE TRIGGER dbo.trg_BinhLuan_NguCanh ON dbo.BinhLuan
AFTER INSERT,UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT 1 FROM inserted i JOIN deleted d ON d.MaBinhLuan=i.MaBinhLuan
        WHERE EXISTS(SELECT i.MaSach,i.MaChuong,i.MaBaiThaoLuan,i.MaBinhLuanCha
                     EXCEPT SELECT d.MaSach,d.MaChuong,d.MaBaiThaoLuan,d.MaBinhLuanCha))
        THROW 50100,N'Khong duoc doi pham vi hoac binh luan cha.',1;
    -- EXCEPT coi hai NULL la bang nhau, tranh bo sot do logic UNKNOWN.
    IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.BinhLuan p ON p.MaBinhLuan=i.MaBinhLuanCha
        WHERE EXISTS(SELECT i.MaSach,i.MaChuong,i.MaBaiThaoLuan
                     EXCEPT SELECT p.MaSach,p.MaChuong,p.MaBaiThaoLuan))
        THROW 50101,N'Cha va con phai cung sach, cung chuong hoac cung bai thao luan.',1;
END;
GO

CREATE TRIGGER dbo.trg_NoiDungChuong_GioiHanAnh ON dbo.NoiDungChuong
AFTER INSERT,UPDATE AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Lock int;
    SELECT @Lock=c.MaChuong FROM dbo.Chuong c WITH(UPDLOCK,HOLDLOCK)
    WHERE c.MaChuong IN(SELECT MaChuong FROM inserted);
    IF EXISTS(SELECT n.MaChuong FROM dbo.NoiDungChuong n
        WHERE n.MaChuong IN(SELECT MaChuong FROM inserted) AND n.KieuTep IN('image/jpeg','image/png','image/webp')
        GROUP BY n.MaChuong HAVING COUNT(*)>50 OR SUM(n.DungLuong)>52428800)
        THROW 50102,N'Moi chuong toi da 50 anh va tong dung luong anh toi da 50 MiB.',1;
END;
GO

CREATE TRIGGER dbo.trg_Sach_KhongDoiLoai ON dbo.Sach
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT 1 FROM inserted i JOIN deleted d ON d.MaSach=i.MaSach
        WHERE i.LoaiTruyen<>d.LoaiTruyen AND EXISTS(SELECT 1 FROM dbo.Chuong c WHERE c.MaSach=i.MaSach))
        THROW 50103,N'Khong doi loai truyen khi da co chuong.',1;
END;
GO

-- Kiem tra tuy chon, fixture rollback.
DECLARE @ChayKiemTra bit=0;
IF @ChayKiemTra=1
BEGIN
SET NOCOUNT ON; SET XACT_ABORT ON;
DECLARE @Setup nvarchar(max)=N'
DECLARE @U int,@A int,@S int,@C1 int,@C2 int,@P int,@BS int,@BC int,@BP int,@Token varchar(32)=LOWER(REPLACE(CONVERT(varchar(36),NEWID()),''-'',''''));
INSERT dbo.TaiKhoan(TenHienThi,Email,MatKhauHash) VALUES(N''Test user'',@Token+''@example.invalid'',N''NOT_A_LOGIN_HASH''); SET @U=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.TaiKhoan(TenHienThi,Email,MatKhauHash,MaVaiTro) VALUES(N''Test author'',''a''+@Token+''@example.invalid'',N''NOT_A_LOGIN_HASH'',''Contributor''); SET @A=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.Sach(TenSach,TacGia,GioiThieu,MaNguoiDang,ChoDuyet) VALUES(N''Sach test'',N''Tac gia'',N''Gioi thieu'',@A,0); SET @S=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.SachTheLoai SELECT TOP(1) @S,MaTheLoai,1 FROM dbo.TheLoai ORDER BY MaTheLoai;
INSERT dbo.Chuong(MaSach,SoChuong,TieuDe) VALUES(@S,1,N''Chuong 1''); SET @C1=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.Chuong(MaSach,SoChuong,TieuDe) VALUES(@S,2,N''Chuong 2''); SET @C2=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.NoiDungChuong(MaChuong,ThuTu,DuongDanTep,KieuTep,TenTepGoc,DungLuong) VALUES
(@C1,1,''test/''+@Token+''/1.txt'',''text/plain'',N''vanban.txt'',100),
(@C1,2,''test/''+@Token+''/2.png'',''image/png'',N''trang.png'',200),
(@C1,3,''test/''+@Token+''/3.pdf'',''application/pdf'',N''tailieu.pdf'',300),
(@C2,1,''test/''+@Token+''/4.md'',''text/markdown'',N''tailieu.md'',100);
INSERT dbo.BaiThaoLuan(MaTaiKhoan,TieuDe,NoiDung) VALUES(@U,N''Chu de doc lap'',N''Van de thao luan''); SET @P=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.BinhLuan(MaSach,MaTaiKhoan,NoiDung) VALUES(@S,@U,N''Ngoai sach''); SET @BS=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.BinhLuan(MaChuong,MaTaiKhoan,NoiDung) VALUES(@C1,@U,N''Trong chuong''); SET @BC=CONVERT(int,SCOPE_IDENTITY());
INSERT dbo.BinhLuan(MaBaiThaoLuan,MaTaiKhoan,NoiDung) VALUES(@P,@U,N''Trong bai''); SET @BP=CONVERT(int,SCOPE_IDENTITY());
';
DECLARE @Cases TABLE(Id int IDENTITY PRIMARY KEY,Ten nvarchar(150),Lenh nvarchar(max),Loi int NULL);
INSERT @Cases VALUES(N'TXT anh PDF cung bang va procedure dang tep',N'IF (SELECT COUNT(*) FROM dbo.NoiDungChuong WHERE MaChuong=@C1)<>3 THROW 51000,N''Thieu noi dung.'',1;
DECLARE @T dbo.DanhSachTepNoiDung; INSERT @T VALUES(1,''test/''+@Token+''/new.pdf'',''application/pdf'',N''moi.pdf'',100);
EXEC dbo.usp_ThemChuong @A,@S,N''Chuong moi'',@T;
IF NOT EXISTS(SELECT 1 FROM dbo.Chuong WHERE MaSach=@S AND SoChuong=3) THROW 51000,N''Chua tao chuong.'',1;
IF NOT EXISTS(SELECT 1 FROM dbo.Sach WHERE MaSach=@S AND ChoDuyet=1) THROW 51000,N''Chua cho duyet.'',1;',NULL);
INSERT @Cases VALUES(N'Ba pham vi va an sach khong an dien dan',N'EXEC dbo.usp_ThemBinhLuan @U,N''Tra loi sach'',@MaSach=@S,@MaBinhLuanCha=@BS;
EXEC dbo.usp_ThemBinhLuan @U,N''Tra loi chuong'',@MaChuong=@C1,@MaBinhLuanCha=@BC;
EXEC dbo.usp_ThemBinhLuan @U,N''Tra loi bai'',@MaBaiThaoLuan=@P,@MaBinhLuanCha=@BP;
DECLARE @N int;
SELECT @N=COUNT(*) FROM dbo.vw_BinhLuanCongKhai WHERE MaSach=@S OPTION(MAXRECURSION 0);
IF @N<>2 THROW 51000,N''Tron binh luan sach.'',1;
SELECT @N=COUNT(*) FROM dbo.vw_BinhLuanCongKhai WHERE MaChuong=@C1 OPTION(MAXRECURSION 0);
IF @N<>2 THROW 51000,N''Tron binh luan chuong.'',1;
UPDATE dbo.Sach SET BiAn=1 WHERE MaSach=@S;
SELECT @N=COUNT(*) FROM dbo.vw_BinhLuanCongKhai WHERE MaSach=@S OR MaChuong=@C1 OPTION(MAXRECURSION 0);
IF @N<>0 THROW 51000,N''Lo binh luan sach an.'',1;
SELECT @N=COUNT(*) FROM dbo.vw_BinhLuanCongKhai WHERE MaBaiThaoLuan=@P OPTION(MAXRECURSION 0);
IF @N<>2 THROW 51000,N''Dien dan bi anh huong boi sach.'',1;
UPDATE dbo.BinhLuan SET BiAn=1 WHERE MaBinhLuan=@BP;
SELECT @N=COUNT(*) FROM dbo.vw_BinhLuanCongKhai WHERE MaBaiThaoLuan=@P OPTION(MAXRECURSION 0);
IF @N<>0 THROW 51000,N''Phan hoi cua cha an van hien.'',1;',NULL);
INSERT @Cases VALUES(N'Tai khoan doc lap va chuyen chuong deu cong luot',N'EXEC dbo.usp_DocChuong @S,1,@U; EXEC dbo.usp_DocChuong @S,1,@U; EXEC dbo.usp_DocChuong @S,2,@U;
IF (SELECT LuotDoc FROM dbo.Sach WHERE MaSach=@S)<>3 THROW 51000,N''Thieu luot doc.'',1;
IF (SELECT COUNT(*) FROM dbo.LuotDocSach WHERE MaSach=@S AND MaTaiKhoan=@U)<>3 THROW 51000,N''Thieu su kien luot doc.'',1;
IF NOT EXISTS(SELECT 1 FROM dbo.LichSuDoc WHERE MaTaiKhoan=@U AND MaSach=@S AND MaChuong=@C2) THROW 51000,N''Sai lich su.'',1;
EXEC dbo.usp_LuuDanhGia @U,@S,5; EXEC dbo.usp_LuuTuSach @U,@S,1;
EXEC dbo.usp_BangXepHang ''Week'';
DECLARE @NoiDung int=(SELECT MIN(MaNoiDung) FROM dbo.NoiDungChuong WHERE MaChuong=@C1);
EXEC dbo.usp_LayTepNoiDung @NoiDung,@U;',NULL);
INSERT @Cases VALUES(N'Khach van chong dem lap 30 phut',N'DECLARE @G uniqueidentifier=NEWID();
EXEC dbo.usp_DocChuong @S,1,NULL,@G; EXEC dbo.usp_DocChuong @S,2,NULL,@G;
IF (SELECT LuotDoc FROM dbo.Sach WHERE MaSach=@S)<>1 THROW 51000,N''Dem trung luot khach.'',1;
IF (SELECT COUNT(*) FROM dbo.LuotDocSach WHERE MaSach=@S AND MaKhach=@G)<>1 THROW 51000,N''Dem trung su kien khach.'',1;',NULL);
INSERT @Cases VALUES(N'Cam phan hoi cheo chuong',N'INSERT dbo.BinhLuan(MaChuong,MaBinhLuanCha,MaTaiKhoan,NoiDung) VALUES(@C2,@BC,@U,N''Sai chuong'');',50101);
INSERT @Cases VALUES(N'Cam phan hoi sach sang chuong',N'INSERT dbo.BinhLuan(MaChuong,MaBinhLuanCha,MaTaiKhoan,NoiDung) VALUES(@C1,@BS,@U,N''Sai pham vi'');',50101);
INSERT @Cases VALUES(N'Cam phan hoi bai sang sach',N'INSERT dbo.BinhLuan(MaSach,MaBinhLuanCha,MaTaiKhoan,NoiDung) VALUES(@S,@BP,@U,N''Sai pham vi'');',50101);
INSERT @Cases VALUES(N'Cam chon hai dich',N'INSERT dbo.BinhLuan(MaSach,MaChuong,MaTaiKhoan,NoiDung) VALUES(@S,@C1,@U,N''Hai dich'');',547);
INSERT @Cases VALUES(N'Cam binh luan khong dich',N'INSERT dbo.BinhLuan(MaTaiKhoan,NoiDung) VALUES(@U,N''Khong dich'');',547);
INSERT @Cases VALUES(N'Cam tu tham chieu',N'UPDATE dbo.BinhLuan SET MaBinhLuanCha=MaBinhLuan WHERE MaBinhLuan=@BP;',547);
INSERT @Cases VALUES(N'Cam duong dan ra ngoai kho',N'UPDATE dbo.NoiDungChuong SET DuongDanTep=''../secret.txt'' WHERE MaChuong=@C1 AND ThuTu=1;',547);
INSERT @Cases VALUES(N'Cam thu tu tep trung',N'UPDATE dbo.NoiDungChuong SET ThuTu=1 WHERE MaChuong=@C1 AND ThuTu=2;',2627);
INSERT @Cases VALUES(N'Cam lich su sai sach',N'INSERT dbo.LichSuDoc(MaTaiKhoan,MaSach,MaChuong) VALUES(@U,-1,@C1);',547);
INSERT @Cases VALUES(N'Cam tra loi cha an',N'UPDATE dbo.BinhLuan SET BiAn=1 WHERE MaBinhLuan=@BP; EXEC dbo.usp_ThemBinhLuan @U,N''Noi dung'',@MaBaiThaoLuan=@P,@MaBinhLuanCha=@BP;',50023);
INSERT @Cases VALUES(N'Cam metadata anh qua 5 MiB',N'UPDATE dbo.NoiDungChuong SET DungLuong=5242881 WHERE MaChuong=@C1 AND ThuTu=2;',547);
DECLARE @I int=1,@N int=(SELECT COUNT(*) FROM @Cases),@Ten nvarchar(150),@Cmd nvarchar(max),@Loi int,@ThucTe int;
WHILE @I<=@N
BEGIN
 SELECT @Ten=Ten,@Cmd=@Setup+Lenh,@Loi=Loi FROM @Cases WHERE Id=@I;
 SET @ThucTe=NULL;
 BEGIN TRY
  BEGIN TRANSACTION;
  EXEC sys.sp_executesql @Cmd;
  IF XACT_STATE()<>0 ROLLBACK;
 END TRY
 BEGIN CATCH
  SET @ThucTe=ERROR_NUMBER();
  IF XACT_STATE()<>0 ROLLBACK;
  IF @Loi IS NULL OR @ThucTe<>@Loi BEGIN PRINT N'FAIL: '+@Ten; THROW; END;
 END CATCH;
 IF @Loi IS NOT NULL AND @ThucTe IS NULL BEGIN PRINT N'FAIL: '+@Ten; THROW 51000,N'Du lieu sai khong bi chan.',1; END;
 PRINT N'PASS: '+@Ten;
 SET @I+=1;
END;
PRINT N'Hoan tat 15 ca kiem tra; fixture da rollback.';
END;
GO

-- Khoi phuc thuc thi sau khi dung nap tren database da co du lieu.
SET NOEXEC OFF;
GO
