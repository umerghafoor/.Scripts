import os
import sys
import subprocess
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton,
    QLabel, QInputDialog, QMessageBox, QSizePolicy, QFrame, QLineEdit
)
from PyQt6.QtCore import Qt, QPoint
from PyQt6.QtGui import QFont

if getattr(sys, 'frozen', False):
    BASE_DIR = sys._MEIPASS  # When bundled with PyInstaller
else:
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # Normal run

SCRIPT_PATH = os.path.join(BASE_DIR, "scripts")

sudo_password = '8637'

class TitleBar(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.start = QPoint(0, 0)

        self.setFixedHeight(80)
        self.setStyleSheet("background-color: transparent; color: #ECEFF4; font-size: 28px;")

        layout = QHBoxLayout(self)
        layout.setContentsMargins(20, 0, 20, 0)

        self.title = QLabel("⚙️ Swap Manager")
        self.title.setStyleSheet("font-weight: bold;")
        layout.addWidget(self.title)

        layout.addStretch()

        close_btn = QPushButton("✖")
        close_btn.setFixedSize(80, 80)
        close_btn.setStyleSheet("background-color: transparent; font-size: 28px; color: #D08770; border: none;")
        close_btn.clicked.connect(self.parent.close)
        layout.addWidget(close_btn)

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.start = event.globalPosition().toPoint() - self.parent.frameGeometry().topLeft()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.MouseButton.LeftButton:
            self.parent.move(event.globalPosition().toPoint() - self.start)

class SwapManager(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.setFixedSize(1000, 1000)
        self.setStyleSheet("""
            QWidget {
                background-color: #2E3440;
                color: #ECEFF4;
                font-family: 'Segoe UI';
                font-size: 28px;
            }
            QPushButton {
                background-color: #5E81AC;
                color: white;
                padding: 24px;
                border-radius: 16px;
                font-size: 28px;
            }
            QPushButton:hover {
                background-color: #81A1C1;
            }
        """)
        self.setup_ui()

    def setup_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)

        self.title_bar = TitleBar(self)
        main_layout.addWidget(self.title_bar)

        content = QVBoxLayout()
        content.setContentsMargins(40, 20, 40, 40)
        content.setSpacing(40)

        # Horizontal swap buttons
        swap_row = QHBoxLayout()
        for size in ["2G", "4G", "8G", "12G", "16G"]:
            btn = QPushButton(f"💾 {size}")
            btn.clicked.connect(lambda _, s=size: self.run_script("swap.sh", [s]))
            btn.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
            swap_row.addWidget(btn)

        content.addLayout(swap_row)

        # Custom button
        custom_btn = QPushButton("🛠️ Custom Size")
        custom_btn.clicked.connect(self.create_swap_custom)
        content.addWidget(custom_btn)

        # Actions
        for label, args in [
            ("🗑️ Delete Last Swap", ["-d"]),
            ("📤 Move Swap to RAM", ["-m"]),
            ("🧹 Clean Unused Swaps", ["-c"]),
        ]:
            btn = QPushButton(label)
            btn.clicked.connect(lambda _, a=args: self.run_script("swap.sh", a))
            content.addWidget(btn)

        # Panel switch
        panel_row = QHBoxLayout()
        panel_label = QLabel("🧭 Switch Panel Mode:")
        panel_label.setStyleSheet("font-size: 28px; font-weight: bold;")
        panel_row.addWidget(panel_label)
        content.addLayout(panel_row)

        btn_panel = QPushButton("🧩 Panel")
        btn_panel.clicked.connect(lambda: self.run_script_no_sudo("panel.sh", ["panel"]))

        btn_dock = QPushButton("📌 Dock")
        btn_dock.clicked.connect(lambda: self.run_script_no_sudo("panel.sh", ["dock"]))

        dock_row = QHBoxLayout()
        dock_row.addWidget(btn_panel)
        dock_row.addWidget(btn_dock)
        content.addLayout(dock_row)

        main_layout.addLayout(content)

    def get_sudo_password(self):
        global sudo_password
        if sudo_password is None:
            password, ok = QInputDialog.getText(self, "🔐 Sudo Password", "Enter your sudo password:", QLineEdit.EchoMode.Password)
            if ok and password:
                sudo_password = password
        return sudo_password

    def run_script(self, script, args=[]):
        try:
            password = self.get_sudo_password()
            if not password:
                QMessageBox.critical(self, "Error", "Sudo password is required.")
                return
            cmd = ['sudo', '-S', 'bash', os.path.join(SCRIPT_PATH, script)] + args
            proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            out, err = proc.communicate(password + '\n')
            if proc.returncode != 0:
                raise Exception(err)
            QMessageBox.information(self, "Success", out or "Done")
        except Exception as e:
            QMessageBox.critical(self, "Error", str(e))

    def run_script_no_sudo(self, script, args=[]):
        try:
            cmd = ['bash', os.path.join(SCRIPT_PATH, script)] + args
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            out, err = proc.communicate()
            if proc.returncode != 0:
                raise Exception(err)
            QMessageBox.information(self, "Success", out or "Done")
        except Exception as e:
            QMessageBox.critical(self, "Error", str(e))

    def create_swap_custom(self):
        path, ok1 = QInputDialog.getText(self, "🛠️ Custom Swap", "Enter swap path (leave empty for home):")
        size, ok2 = QInputDialog.getText(self, "💾 Swap Size", "Enter custom swap size (e.g. 5G):")
        if not ok2 or not size:
            QMessageBox.critical(self, "Error", "Swap size is required.")
            return
        args = [path, size] if path else [size]
        self.run_script("swap.sh", args)

if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Global font scaling
    font = QFont("Segoe UI", 28)  # Scaled up font
    app.setFont(font)

    win = SwapManager()
    win.show()
    sys.exit(app.exec())
