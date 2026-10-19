-- Cap nhat database dang dung; giu nguyen du lieu hien co.
USE [SachMoiDaDen];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_DocChuong]
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
